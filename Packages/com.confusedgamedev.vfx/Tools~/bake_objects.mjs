// Bakes the 00GameDevs object modules into data for VfxObjectImporter. Unity ignores this folder.
//
// usage: node bake_objects.mjs <source dir> <output dir>
//
// <source dir> holds objects.json (the catalog's kind:"object" entries), modules/<id>.mjs and
// node_modules/three at 0.187.0. Geometry stays in the source's axes: the importer converts it.
import fs from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';

const [source, output] = process.argv.slice(2);
const objects = JSON.parse(fs.readFileSync(path.join(source, 'objects.json'), 'utf8'));
fs.mkdirSync(output, { recursive: true });

const folderName = id => id.split('-').map(part => part[0].toUpperCase() + part.slice(1)).join('');
const base64 = values => Buffer.from(new Float32Array(values).buffer).toString('base64');
const hasTexture = attrs => attrs.includes('brushData');

// Modules emit flat triangles. Welding identical vertices keeps the baked meshes small.
function weld(streams, count) {
  const seen = new Map(), out = streams.map(() => []), indices = [];
  const width = streams.map(s => s.size);
  for (let i = 0; i < count; i++) {
    let key = '';
    for (let s = 0; s < streams.length; s++) {
      for (let c = 0; c < width[s]; c++) key += streams[s].data[i * width[s] + c] + ',';
    }
    let index = seen.get(key);
    if (index === undefined) {
      index = seen.size;
      seen.set(key, index);
      for (let s = 0; s < streams.length; s++) {
        for (let c = 0; c < width[s]; c++) out[s].push(streams[s].data[i * width[s] + c]);
      }
    }
    indices.push(index);
  }
  return { out, indices };
}

function flatten(geometry) {
  return geometry.index ? geometry.toNonIndexed() : geometry;
}

function roleOf(mesh) {
  const match = /palette-(\d)$/.exec(mesh.name);
  return match ? Number(match[1]) : 0;
}

// The basic sword paints roles into vertex colours, so three marker colours recover them.
function splitBasic(asset, mesh) {
  asset.setOptions({ primary: '#ff0000', secondary: '#00ff00', accent: '#0000ff' });
  const g = mesh.geometry, count = g.attributes.position.count, parts = [[], [], []];
  for (let i = 0; i < count; i++) {
    const r = g.attributes.color.getX(i), gr = g.attributes.color.getY(i);
    parts[r > .5 ? 0 : gr > .5 ? 1 : 2].push(i);
  }
  return parts.map((list, role) => ({ role, list })).filter(p => p.list.length);
}

function bakeLit(asset, meshes, family) {
  const vertices = { position: [], normal: [], tone: [] }, roles = [];
  let base = 0;
  const pieces = [];
  for (const mesh of meshes) {
    const g = flatten(mesh.geometry);
    if (family === 'basic') {
      for (const { role, list } of splitBasic(asset, mesh)) pieces.push({ role, g, list });
    } else {
      pieces.push({ role: roleOf(mesh), g, list: null });
    }
  }
  for (const { role, g, list } of pieces) {
    const order = list ?? Array.from({ length: g.attributes.position.count }, (_, i) => i);
    const position = [], normal = [], tone = [];
    for (const i of order) {
      position.push(g.attributes.position.getX(i), g.attributes.position.getY(i), g.attributes.position.getZ(i));
      normal.push(g.attributes.normal.getX(i), g.attributes.normal.getY(i), g.attributes.normal.getZ(i));
      tone.push(family === 'basic' ? 1 : g.attributes.color.getX(i));
    }
    const { out, indices } = weld([{ data: position, size: 3 }, { data: normal, size: 3 }, { data: tone, size: 1 }], order.length);
    vertices.position.push(...out[0]);
    vertices.normal.push(...out[1]);
    vertices.tone.push(...out[2]);
    roles.push({ role, indices: indices.map(i => i + base) });
    base += out[2].length;
  }
  return {
    position: base64(vertices.position), normal: base64(vertices.normal), tone: base64(vertices.tone),
    vertexCount: base, roles
  };
}

function bakeVegetation(mesh) {
  const g = mesh.geometry, a = g.attributes, count = a.position.count;
  const streams = [['position', 3], ['normal', 3], ['uv', 2], ['brushData', 4], ['plantRoot', 2], ['leafMotion', 4]]
    .map(([name, size]) => ({ name, size, data: Array.from(a[name].array) }));
  const { out, indices } = weld(streams, count);
  const baked = { vertexCount: out[0].length / 3, roles: [{ role: 0, indices }] };
  streams.forEach((s, i) => { baked[s.name] = base64(out[i]); });
  return baked;
}

function boundsOf(asset, mesh) {
  const box = asset.animationBounds ?? mesh.geometry.boundingBox;
  return box ? { min: box.min.toArray(), max: box.max.toArray() } : null;
}

let done = 0;
for (const entry of objects) {
  const mod = await import(pathToFileURL(path.join(source, 'modules', entry.id + '.mjs')).href);
  const asset = mod.default();
  const meshes = [];
  asset.group.traverse(node => {
    if (node.isMesh && !node.userData.objectEffect && node.parent === asset.group) meshes.push(node);
  });

  const family = entry.integration.materialFamily;
  const baked = family === 'vegetation' ? bakeVegetation(meshes[0]) : bakeLit(asset, meshes, family);
  const firePoints = (asset.firePoints ?? []).map(point => {
    const q = point.quaternion;
    return { id: point.name, position: point.position.toArray(), rotation: [q.x, q.y, q.z, q.w] };
  });

  fs.writeFileSync(path.join(output, folderName(entry.id) + '.json'), JSON.stringify({
    id: entry.id,
    folder: folderName(entry.id),
    displayName: entry.name.en,
    description: entry.description?.en ?? '',
    category: entry.category,
    family,
    origin: asset.group.userData.origin ?? 'base-center',
    primary: mod.defaultOptions.primary,
    secondary: mod.defaultOptions.secondary,
    accent: mod.defaultOptions.accent,
    triangles: asset.stats.triangles,
    firing: firePoints.length > 0,
    firePoints,
    bounds: family === 'vegetation' ? boundsOf(asset, meshes[0]) : null,
    mesh: baked
  }));
  asset.dispose();
  done++;
}
console.log(`baked ${done} objects into ${output}`);
