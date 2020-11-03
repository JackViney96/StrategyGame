using NaughtyAttributes;
using System;
using UnityEngine;
using UnityEngine.InputSystem;

[Serializable]
public class StandardCameraController : MonoBehaviour, PCT.Camera.ICameraController
{
    [SerializeField]
    private TerrainReferenceHolder referenceHolder;

    [SerializeField]
    private float cameraSensitivity = 90;

    [SerializeField]
    private LayerMask layerMask;

    [MinMaxSlider(0.0f, 1000f)]
    [SerializeField]
    private Vector2 SpeedMinMax;

    [SerializeField]
    private float speedStep = 2f;

    [SerializeField]
    private float verticalSpeedDivisor = 2f;

    public Camera camera;
    float[] distances = new float[32];
    public float grassDistance = 15;

    private float rotationX = 0.0f;
    private float rotationY = 0.0f;
    private bool rotationDesired = false;

    private Vector2 desiredDirectionXZ = Vector2.zero;
    private float desiredDirectionY = 0f;
    private Vector2 scrollWheel = Vector2.zero;

    public float desiredSpeed
    {
        get { return _desiredSpeed; }
        set
        {
            _desiredSpeed = Mathf.Clamp(value, SpeedMinMax.x, SpeedMinMax.y);
        }
    }

    private float _desiredSpeed;

    private float normalSpeed;

    private Vector3 deltaPos;
    private Vector3 goalPos;

    private void Start()
    {
        //TODO; de-hardcode?
        desiredSpeed = 50f;
        camera.layerCullSpherical = false;
#if !UNITY_EDITOR
        Cursor.lockState = CursorLockMode.Confined;
        //Cursor.visible = false;
#endif
    }

    #region Input Methods

    //Movement
    public void OnCameraPan(InputValue value)
    {
        desiredDirectionXZ = value.Get<Vector2>();
    }

    public void OnCameraRotate(InputValue value)
    {
        if (value.isPressed)
        {
            rotationDesired = true;
        }
        else
        {
            rotationDesired = false;
        }
    }

    public void OnCameraAltitude(InputValue value)
    {
        desiredDirectionY = value.Get<float>();
    }

    public void OnCameraSpeed(InputValue value)
    {
        scrollWheel = value.Get<Vector2>();
    }

    public void OnCameraFast(InputValue value)
    {
        if (value.isPressed)
        {
            normalSpeed = desiredSpeed;
            desiredSpeed = SpeedMinMax.y;
        }
        else
        {
            desiredSpeed = normalSpeed;
        }
    }

    #endregion Input Methods

    private void AdjustSpeed(float scrollWheelY)
    {
        if (scrollWheelY > 0f)
        {
            desiredSpeed += speedStep;
        }
        else if (scrollWheelY < 0f)
        {
            desiredSpeed -= speedStep;
        }
    }

    public void Rotate()
    {
        //TODO: Rotate around focus point
        rotationX += Input.GetAxis("Mouse X") * cameraSensitivity * Time.deltaTime;
        rotationY += Input.GetAxis("Mouse Y") * cameraSensitivity * Time.deltaTime;
        rotationY = Mathf.Clamp(rotationY, -90, 90);

        transform.localRotation = Quaternion.AngleAxis(rotationX, Vector3.up);
        transform.localRotation *= Quaternion.AngleAxis(rotationY, Vector3.left);
    }

    private void Update()
    {
        if (referenceHolder == null)
        {
            return;
        }

        AdjustSpeed(scrollWheel.y);
        if (rotationDesired)
            Rotate();

        Move();

        distances[8] = grassDistance;
        camera.layerCullDistances = distances;
    }

    public void Move()
    {
        deltaPos = Vector3.zero;
        deltaPos = ((transform.forward * desiredDirectionXZ.y) + (transform.right * desiredDirectionXZ.x)).normalized * Time.deltaTime * desiredSpeed;

        //Perform Checks
        RaycastHit hit;
        Physics.Raycast(transform.position, Vector3.down, out hit, Mathf.Infinity, layerMask);

        if (hit.distance > 2.5)
        {
            deltaPos.y = desiredDirectionY * Time.deltaTime * (desiredSpeed / verticalSpeedDivisor);
        }
        else
        {
            deltaPos.y = Mathf.Abs(deltaPos.y);
        }

        goalPos = transform.position + deltaPos;

        if (referenceHolder.terrainBounds.Contains(goalPos))
        {
            transform.position = goalPos;
        }
    }
}