using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PinchDetection : MonoBehaviour
{
    [SerializeField]
    private float cameraSpeed = 4f;

    private TouchControls controls;
    private Coroutine zoomCoroutine;
    private Transform cameraTransform;

    private void Awake()
    {
        controls = new TouchControls();
        cameraTransform = Camera.main.transform;
    }

    private void OnEnable()
    {
        controls.Enable();
    }

    private void OnDisable()
    {
        controls.Disable();
    }

    private void Start()
    {
        controls.Touch.PrimaryTouchContact.started += _ => Test();
        controls.Touch.SecondaryTouchContact.started += _ => ZoomStart();
        controls.Touch.SecondaryTouchContact.canceled += _ => ZoomEnd();
    }

    private void Test()
    {
        Debug.Log(controls.Touch.PrimaryFingerPosition.ReadValue<Vector2>().x);
    }


    private void ZoomStart()
    {
        zoomCoroutine = StartCoroutine(ZoomDetection());
    }

    private void ZoomEnd()
    {
        StopCoroutine(zoomCoroutine);
    }

    IEnumerator ZoomDetection()
    {
        float previousDistance = 0f, distance = 0f;
        while(true)
        {
            distance = Vector2.Distance(controls.Touch.PrimaryFingerPosition.ReadValue<Vector2>(),
                controls.Touch.SecondaryFingerPosition.ReadValue<Vector2>());

            if(distance > previousDistance)
            {
                Vector3 targetPosition = cameraTransform.position;
                targetPosition.z -= 1;
                cameraTransform.position = Vector3.Slerp(cameraTransform.position,
                    targetPosition, Time.deltaTime * cameraSpeed);
            }
            else if(distance < previousDistance)
            {
                Vector3 targetPosition = cameraTransform.position;
                targetPosition.z += 1;
                cameraTransform.position = Vector3.Slerp(cameraTransform.position,
                    targetPosition, Time.deltaTime * cameraSpeed);
            }

            previousDistance = distance;
            yield return null;
        }
    }
}
