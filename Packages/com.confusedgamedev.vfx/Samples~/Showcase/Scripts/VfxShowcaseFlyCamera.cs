using UnityEngine;
using UnityEngine.InputSystem;

namespace ConfusedGameDev.Vfx.Showcase
{
    /// <summary>WASD to move, Q and E for down and up, right-drag to look, middle-drag to pan, Shift to go faster.</summary>
    public sealed class VfxShowcaseFlyCamera : MonoBehaviour
    {
        private const float GlideRate = 4f;
        private const float GlideEnd = 0.02f;

        [SerializeField, Min(0.1f)] private float speed = 6f;
        [SerializeField, Min(1f)] private float fastMultiplier = 3f;
        [SerializeField, Min(0f)] private float lookSpeed = 0.15f;
        [Tooltip("Metres per pixel dragged.")]
        [SerializeField, Min(0f)] private float panSpeed = 0.01f;

        private bool gliding;
        private Vector3 glidePosition;
        private Quaternion glideRotation;
        private float yaw;
        private float pitch;

        public bool IsGliding => gliding;

        /// <summary>Flies to a pose. Moving or looking ends the glide early.</summary>
        public void Glide(Vector3 position, Quaternion rotation)
        {
            glidePosition = position;
            glideRotation = rotation;
            gliding = true;
        }

        private void OnEnable()
        {
            SyncLook();
        }

        private void Update()
        {
            Vector3 move = ReadMove();
            Vector2 look = ReadLook();
            Vector2 pan = ReadPan();

            if (move != Vector3.zero || look != Vector2.zero || pan != Vector2.zero)
            {
                gliding = false;
            }

            if (gliding)
            {
                float blend = 1f - Mathf.Exp(-GlideRate * Time.unscaledDeltaTime);
                transform.SetPositionAndRotation(
                    Vector3.Lerp(transform.position, glidePosition, blend),
                    Quaternion.Slerp(transform.rotation, glideRotation, blend));

                if (Vector3.Distance(transform.position, glidePosition) < GlideEnd)
                {
                    gliding = false;
                }

                SyncLook();
                return;
            }

            yaw += look.x * lookSpeed;
            pitch = Mathf.Clamp(pitch - look.y * lookSpeed, -89f, 89f);
            transform.rotation = Quaternion.Euler(pitch, yaw, 0f);
            transform.position += transform.rotation * move * (speed * Time.unscaledDeltaTime);

            // The view follows the hand, as if dragging the hall.
            transform.position -= transform.rotation * pan * panSpeed;
        }

        private Vector3 ReadMove()
        {
            Keyboard keyboard = Keyboard.current;
            if (keyboard == null)
            {
                return Vector3.zero;
            }

            var move = new Vector3(
                Axis(keyboard.aKey, keyboard.dKey),
                Axis(keyboard.qKey, keyboard.eKey),
                Axis(keyboard.sKey, keyboard.wKey));
            return keyboard.leftShiftKey.isPressed ? move * fastMultiplier : move;
        }

        private static Vector2 ReadLook()
        {
            Mouse mouse = Mouse.current;
            return mouse != null && mouse.rightButton.isPressed ? mouse.delta.ReadValue() : Vector2.zero;
        }

        private static Vector2 ReadPan()
        {
            Mouse mouse = Mouse.current;
            return mouse != null && mouse.middleButton.isPressed ? mouse.delta.ReadValue() : Vector2.zero;
        }

        private static float Axis(UnityEngine.InputSystem.Controls.KeyControl negative, UnityEngine.InputSystem.Controls.KeyControl positive)
        {
            return (positive.isPressed ? 1f : 0f) - (negative.isPressed ? 1f : 0f);
        }

        private void SyncLook()
        {
            Vector3 angles = transform.eulerAngles;
            yaw = angles.y;
            pitch = Mathf.DeltaAngle(0f, angles.x);
        }
    }
}
