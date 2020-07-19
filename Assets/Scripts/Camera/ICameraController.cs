using UnityEngine.InputSystem;

namespace PCT.Camera
{
    public interface ICameraController
    {
        void OnCameraPan(InputValue value);

        void OnCameraRotate(InputValue value);

        void OnCameraAltitude(InputValue value);

        void OnCameraSpeed(InputValue value);

        void OnCameraFast(InputValue value);

        void Rotate();

        void Move();
    }
}