using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FollowCam : MonoBehaviour
{
    public Transform target;
    public Vector2 cameraHalfSize = new Vector2(5.0f, 3.0f);
    public Vector3 targetOffset = new Vector3(0.0f, 4.0f, -10.0f);
    public Vector4 cameraBounds = new Vector4(15f, 15f, -15f, -15f); //maxX, maxZ, minX, minZ
    public Vector4 cameraBounds2D = new Vector4(5f, 5f, -5f, -5f); //maxX, maxZ, minX, minZ

    public Button dToogleButton;
    private bool dMode = false; //false 2D, true 3D
    private Camera cameraComponent, backPassCamera;

    private AdventurerScript3D targetScript;

    private void Start()
    {
        cameraComponent = GetComponent<Camera>();
        backPassCamera = transform.GetChild(0).GetComponent<Camera>();
        targetScript = target.GetComponent<AdventurerScript3D>();
        dToogleButton.onClick.AddListener(() => { DTooglePressed(dMode); });
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.X))
        {
            DTooglePressed(dMode);
        }

        if (dMode)
        {
            Vector3 clampedPos = new Vector3(
                Mathf.Clamp(target.position.x + targetOffset.x, cameraBounds.z, cameraBounds.x),
                target.position.y + targetOffset.y,
                Mathf.Clamp(target.position.z + targetOffset.z, cameraBounds.w, cameraBounds.y));

            transform.position = clampedPos;

            if (transform.position.x == cameraBounds.x || transform.position.x == cameraBounds.z
            || transform.position.z == cameraBounds.y || transform.position.z == cameraBounds.w)
            {
                transform.LookAt(target);
            }

            targetScript.invertMove = map(System.Convert.ToInt32(transform.position.z < target.position.z), 0, 1, -1, 1);

        } else if(!dMode)
        {
            Vector3 clampedPos = new Vector3(
                Mathf.Clamp(target.position.x + targetOffset.x, cameraBounds2D.z, cameraBounds2D.x),
                Mathf.Clamp(target.position.y + targetOffset.y - 2.0f, cameraBounds2D.w, cameraBounds2D.y),
                target.position.z + targetOffset.z);
            
            transform.position = clampedPos;
        }

        
    }

    private int map(int value, int low1, int high1, int low2, int high2)
    {
        return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
    }

    private void DTooglePressed(bool pressed)
    {
        dMode = !dMode;
        backPassCamera.orthographic = cameraComponent.orthographic = pressed;
        transform.eulerAngles = new Vector3(25.0f * System.Convert.ToInt32(!pressed), 0.0f, 0.0f);
    }

    private void OnApplicationQuit()
    {
        dToogleButton.onClick.RemoveAllListeners();
    }
}
