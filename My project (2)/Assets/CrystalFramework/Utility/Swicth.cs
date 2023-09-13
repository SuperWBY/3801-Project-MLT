using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Swicth : MonoBehaviour
{
    public static Swicth ins;
    private GameObject[] pages;

    void Awake() {
        ins = this;
        pages = GameObject.FindGameObjectsWithTag("switch");

    }

    void Start()
    {
        switchUIPage("MLCanvas");
    }

    public void switchUIPage(string pageName)
    {
        foreach(GameObject page in pages) 
        {
            if(pageName == page.name)
            {
                page.GetComponent<Canvas>().enabled = true;
            } else 
            {
                page.GetComponent<Canvas>().enabled = false;
            }
            
        }
    }
}
