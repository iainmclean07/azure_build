using UnityEngine;
using UnityEngine.XR;
using System.Collections.Generic;
using Ubiq.Logging;

public class CameraLogger : MonoBehaviour
{

    ExperimentLogEmitter events;

    void Start()
    {
        events = new ExperimentLogEmitter(this);
        Debug.Log("XRTracker is starting...");
    }

    void Update()
    {

        // Get head position and rotation
        List<XRNodeState> nodeStates = new List<XRNodeState>();
        InputTracking.GetNodeStates(nodeStates);
        foreach (XRNodeState nodeState in nodeStates)
        {
            if (nodeState.nodeType == XRNode.Head)
            {
                Vector3 headPosition;
                Quaternion headRotation;
                if (nodeState.TryGetPosition(out headPosition) && nodeState.TryGetRotation(out headRotation))
                {
                    events.Log($"Head Position: {headPosition}, Rotation: {headRotation}");
                    Debug.Log($"Head Position: {headPosition}, Rotation: {headRotation}");
            
                }
            }
    
            // Get left and right hand/controller positions
            TrackController(XRNode.LeftHand, "Left Hand");
            TrackController(XRNode.RightHand, "Right Hand");
        }

        CaptureControllerInputs();
    
    }

    private void TrackController(XRNode node, string name)
    {
        List<XRNodeState> nodeStates = new List<XRNodeState>();
        InputTracking.GetNodeStates(nodeStates);
        foreach (XRNodeState nodeState in nodeStates)
        {
            if (nodeState.nodeType == node)
            {
                Vector3 position;
                Quaternion rotation;
                if (nodeState.TryGetPosition(out position) && nodeState.TryGetRotation(out rotation))
                {
                    events.Log($"{name} Position: {position}, Rotation: {rotation}");
                    Debug.Log($"{name} Position: {position}, Rotation: {rotation}");
                }
            }
        }
    }

    void CaptureControllerInputs()
    {
        InputDevice leftController = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        InputDevice rightController = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);

        // Track left primary button press
        if (leftController.TryGetFeatureValue(CommonUsages.primaryButton, out bool primaryButtonPressed) && primaryButtonPressed)
        {
            events.Log("Left Controller Primary Button Pressed");
        }

        // Track right trigger value
        if (rightController.TryGetFeatureValue(CommonUsages.trigger, out float triggerValue))
        {
            events.Log($"Right Trigger Value: {triggerValue}");
        }

        // Track right joystick movement
        if (rightController.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 joystickValue))
        {
            events.Log($"Right Joystick: {joystickValue}");
        }
    }

}
