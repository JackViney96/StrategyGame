using UnityEngine;
using System.Collections;
using UnityEngine.InputSystem;
using NaughtyAttributes;
using PCT.Camera;
using System;

[Serializable]
public class StandardCameraController : MonoBehaviour, PCT.Camera.ICameraController
{
    [SerializeField]
    private TerrainReferenceHolder referenceHolder;
    [SerializeField]
    float cameraSensitivity = 90;

    [SerializeField]
    LayerMask layerMask;

    [MinMaxSlider(0.0f, 1000f)]
    [SerializeField]
    Vector2 SpeedMinMax;
    [SerializeField]
    float speedStep = 2f;

    [SerializeField]
    private float verticalSpeedDivisor = 2f;

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

    private Vector3 deltaPos;
    private Vector3 goalPos;


    void Start()
    {
        //TODO; de-hardcode?
        desiredSpeed = 50f;
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
        throw new System.NotImplementedException();
    }

    #endregion

    void AdjustSpeed(float scrollWheelY)
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

    void Update()
    {
        if (referenceHolder == null)
        {
            return; 
        }

        AdjustSpeed(scrollWheel.y);
        if (rotationDesired)
            Rotate();

        Move();
    }

    public void Move()
    {
        deltaPos = Vector3.zero;
        deltaPos = ((transform.forward * desiredDirectionXZ.y) + (transform.right * desiredDirectionXZ.x)).normalized * Time.deltaTime * desiredSpeed;



        //Perform Checks
        RaycastHit hit;
        Physics.Raycast(transform.position, Vector3.down, out hit, Mathf.Infinity, layerMask);

        if (hit.distance > 5)
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