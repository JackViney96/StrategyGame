// GENERATED AUTOMATICALLY FROM 'Assets/Input/InputMaster.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class @InputMaster : IInputActionCollection, IDisposable
{
    public InputActionAsset asset { get; }
    public @InputMaster()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""InputMaster"",
    ""maps"": [
        {
            ""name"": ""Main"",
            ""id"": ""b2f7b2bf-d4b6-47f5-b956-71b972f441ea"",
            ""actions"": [
                {
                    ""name"": ""CameraPan"",
                    ""type"": ""Value"",
                    ""id"": ""25de8933-e2d7-4897-adfe-f300181eadac"",
                    ""expectedControlType"": ""Dpad"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""CameraRotate"",
                    ""type"": ""Value"",
                    ""id"": ""7a075f2c-f648-4bf1-9070-0ce1446b7ff1"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""CameraAltitude"",
                    ""type"": ""Value"",
                    ""id"": ""d0ca4efc-ec0b-4f5b-98f4-af43cbb15e68"",
                    ""expectedControlType"": ""Digital"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""CameraFast"",
                    ""type"": ""Value"",
                    ""id"": ""22495d75-ef1d-47b3-9743-e4b3021b2be4"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""CameraSpeed"",
                    ""type"": ""Value"",
                    ""id"": ""02743ffc-5d90-4332-8e7e-5db79dd030bc"",
                    ""expectedControlType"": ""Axis"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""2D Vector"",
                    ""id"": ""2fa430df-7b9c-415f-97f1-18e4ebd45cae"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraPan"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""05125abf-5ea3-4731-9190-bae6d4b6cbf7"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraPan"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""397142ef-438d-4295-a529-49a803b67756"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraPan"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""bc6467d9-95a2-4495-880f-326ba5ae44de"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraPan"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""568f49f2-9eb6-4120-a288-a3d738c344c1"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraPan"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""4ee8335d-55a5-447c-b999-00bcea8d0fe4"",
                    ""path"": ""<Mouse>/rightButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraRotate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""1D Axis"",
                    ""id"": ""2a2c3e10-e4fb-4e29-b03b-b67d5f84307e"",
                    ""path"": ""1DAxis"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraAltitude"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""negative"",
                    ""id"": ""a4a6804c-a426-4804-981a-4990897bfe2d"",
                    ""path"": ""<Keyboard>/e"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraAltitude"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""positive"",
                    ""id"": ""617d076f-7628-4725-aacd-d7c00f4ba6fb"",
                    ""path"": ""<Keyboard>/q"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraAltitude"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""44d716ec-e2f4-4d42-bf5c-45e22f157b6e"",
                    ""path"": ""<Keyboard>/shift"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraFast"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""aab0a7e6-32e4-44f9-a687-28c449444926"",
                    ""path"": ""<Mouse>/scroll"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""CameraSpeed"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        }
    ],
    ""controlSchemes"": []
}");
        // Main
        m_Main = asset.FindActionMap("Main", throwIfNotFound: true);
        m_Main_CameraPan = m_Main.FindAction("CameraPan", throwIfNotFound: true);
        m_Main_CameraRotate = m_Main.FindAction("CameraRotate", throwIfNotFound: true);
        m_Main_CameraAltitude = m_Main.FindAction("CameraAltitude", throwIfNotFound: true);
        m_Main_CameraFast = m_Main.FindAction("CameraFast", throwIfNotFound: true);
        m_Main_CameraSpeed = m_Main.FindAction("CameraSpeed", throwIfNotFound: true);
    }

    public void Dispose()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes => asset.controlSchemes;

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // Main
    private readonly InputActionMap m_Main;
    private IMainActions m_MainActionsCallbackInterface;
    private readonly InputAction m_Main_CameraPan;
    private readonly InputAction m_Main_CameraRotate;
    private readonly InputAction m_Main_CameraAltitude;
    private readonly InputAction m_Main_CameraFast;
    private readonly InputAction m_Main_CameraSpeed;
    public struct MainActions
    {
        private @InputMaster m_Wrapper;
        public MainActions(@InputMaster wrapper) { m_Wrapper = wrapper; }
        public InputAction @CameraPan => m_Wrapper.m_Main_CameraPan;
        public InputAction @CameraRotate => m_Wrapper.m_Main_CameraRotate;
        public InputAction @CameraAltitude => m_Wrapper.m_Main_CameraAltitude;
        public InputAction @CameraFast => m_Wrapper.m_Main_CameraFast;
        public InputAction @CameraSpeed => m_Wrapper.m_Main_CameraSpeed;
        public InputActionMap Get() { return m_Wrapper.m_Main; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(MainActions set) { return set.Get(); }
        public void SetCallbacks(IMainActions instance)
        {
            if (m_Wrapper.m_MainActionsCallbackInterface != null)
            {
                @CameraPan.started -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraPan;
                @CameraPan.performed -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraPan;
                @CameraPan.canceled -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraPan;
                @CameraRotate.started -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraRotate;
                @CameraRotate.performed -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraRotate;
                @CameraRotate.canceled -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraRotate;
                @CameraAltitude.started -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraAltitude;
                @CameraAltitude.performed -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraAltitude;
                @CameraAltitude.canceled -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraAltitude;
                @CameraFast.started -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraFast;
                @CameraFast.performed -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraFast;
                @CameraFast.canceled -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraFast;
                @CameraSpeed.started -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraSpeed;
                @CameraSpeed.performed -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraSpeed;
                @CameraSpeed.canceled -= m_Wrapper.m_MainActionsCallbackInterface.OnCameraSpeed;
            }
            m_Wrapper.m_MainActionsCallbackInterface = instance;
            if (instance != null)
            {
                @CameraPan.started += instance.OnCameraPan;
                @CameraPan.performed += instance.OnCameraPan;
                @CameraPan.canceled += instance.OnCameraPan;
                @CameraRotate.started += instance.OnCameraRotate;
                @CameraRotate.performed += instance.OnCameraRotate;
                @CameraRotate.canceled += instance.OnCameraRotate;
                @CameraAltitude.started += instance.OnCameraAltitude;
                @CameraAltitude.performed += instance.OnCameraAltitude;
                @CameraAltitude.canceled += instance.OnCameraAltitude;
                @CameraFast.started += instance.OnCameraFast;
                @CameraFast.performed += instance.OnCameraFast;
                @CameraFast.canceled += instance.OnCameraFast;
                @CameraSpeed.started += instance.OnCameraSpeed;
                @CameraSpeed.performed += instance.OnCameraSpeed;
                @CameraSpeed.canceled += instance.OnCameraSpeed;
            }
        }
    }
    public MainActions @Main => new MainActions(this);
    public interface IMainActions
    {
        void OnCameraPan(InputAction.CallbackContext context);
        void OnCameraRotate(InputAction.CallbackContext context);
        void OnCameraAltitude(InputAction.CallbackContext context);
        void OnCameraFast(InputAction.CallbackContext context);
        void OnCameraSpeed(InputAction.CallbackContext context);
    }
}
