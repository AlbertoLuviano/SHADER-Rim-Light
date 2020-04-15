using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(CapsuleCollider))]
public class AdventurerScript3D : MonoBehaviour
{
    public float topVelocity = 3f, runAccel = 12f, jumpPow = 4f;
    
    private Rigidbody kidRB;
    private SpriteRenderer kidSprite;

    private float doJumpTimer = 0.0f;
    private bool timerIsActive = false, isOnFloor = false;
    private Animator kidAnim;
    private AnimatorStateInfo animStateInfo;
    private GameObject shield;

    public float gravity = -9.8f;
    public float jumpForce = 5f;
    public float xVelocity = 2f;

    [HideInInspector]
    public int invertMove = 1;

    public Button shieldButton;
    private bool shieldOnOff = true;

    private void Start()
    {
        kidAnim = GetComponent<Animator>();
        kidRB = GetComponent<Rigidbody>();
        kidSprite = GetComponent<SpriteRenderer>();
        shield = transform.GetChild(0).gameObject;
        shield.SetActive(false);
        shieldButton.onClick.AddListener(() => { ShieldToogle(shieldOnOff); });
    }

    private void Update()
    {
        animStateInfo = kidAnim.GetCurrentAnimatorStateInfo(0);

        if (Input.GetKeyDown(KeyCode.C))
        {
            ShieldToogle(shieldOnOff);
        }

        if (timerIsActive)
        {
            if (doJumpTimer >= 0.0f)
            {
                doJumpTimer -= Time.deltaTime;
            }
            else
            {
                timerIsActive = false;
                doJumpTimer = 0.0f;
            }
            
        }

        if (Input.GetButtonDown("Jump"))
        {
            doJumpTimer = 0.1f;
            timerIsActive = true;
        }

        if (isOnFloor)
        {
            if (Mathf.Abs(kidRB.velocity.y) <= 0.1f)
            {
                kidRB.velocity = new Vector2(kidRB.velocity.x, 0.0f);
                if (animStateInfo.IsName("Fall")) kidAnim.SetTrigger("Land");
            }

            if (doJumpTimer > 0.0f)
            {
                kidRB.velocity = new Vector2(kidRB.velocity.x, jumpForce);
                if(!animStateInfo.IsName("Jump")) kidAnim.SetTrigger("Jump");
                isOnFloor = false;
            }

            if (Input.GetButton("Attack"))
            {
                kidRB.velocity = Vector3.zero;
                kidAnim.SetTrigger("Attack");
            } else
            {
                kidAnim.SetTrigger("AttackStop");
            }
        } else
        {
            if (kidRB.velocity.y > 0.0f)
            {
                if (Input.GetButtonUp("Jump")) 
                    kidRB.velocity = new Vector2(kidRB.velocity.x, kidRB.velocity.y * 0.5f);
            } 
            else if(kidRB.velocity.y < 0.0f && kidRB.velocity.y > -0.5f)
            {
                kidAnim.SetTrigger("Fall");
            }
            kidRB.velocity = new Vector2(kidRB.velocity.x, kidRB.velocity.y + (gravity * Time.deltaTime));
        }

        if (!animStateInfo.IsName("Attack"))
        {
            kidRB.velocity = new Vector3(Input.GetAxis("Horizontal") * xVelocity * invertMove,
                                        kidRB.velocity.y, Input.GetAxis("Vertical") * xVelocity);
            if (kidRB.velocity.x != 0.0f || kidRB.velocity.z != 0.0f)
            {
                kidSprite.flipX = (kidRB.velocity.x < 0.0f);
                if (!(animStateInfo.IsName("Jump") || animStateInfo.IsName("Fall")))
                {
                    if (animStateInfo.IsName("Idle")) kidAnim.SetTrigger("Run");
                }
            }
            else
            {
                if (!(animStateInfo.IsName("Jump") || animStateInfo.IsName("Fall")))
                {
                    if (animStateInfo.IsName("Run")) kidAnim.SetTrigger("RunStop");
                }
            }
        }

        //Don't overuse Raycasts!, and adventurer layer is set to "IgnoreRaycast"
        isOnFloor = (Physics.Raycast(transform.position + Vector3.left * 0.4f, Vector2.down, 1f) ||
            Physics.Raycast(transform.position + Vector3.right * 0.4f, Vector2.down, 1f) ||
            Physics.Raycast(transform.position + Vector3.forward * 0.4f, Vector2.down, 1f) ||
            Physics.Raycast(transform.position + Vector3.back * 0.4f, Vector2.down, 1f));
        //Debug.DrawRay(transform.position + Vector3.left * 0.5f, Vector2.down * 0.9f, Color.red);
    }

    private void ShieldToogle(bool pressed)
    {
        shieldOnOff = !shieldOnOff;
        shield.SetActive(pressed);
    }

    private void OnApplicationQuit()
    {
        shieldButton.onClick.RemoveAllListeners();
    }
}