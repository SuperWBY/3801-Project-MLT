using UnityEngine;
//using TMpro;

public class Footerbtns : MonoBehaviour {
   // public GameObject Header;

    public void topage(string pageName) {
        Swicth.ins.switchUIPage(pageName);
       // Header = GameObject.FindGameObjectWithTag("Header");
       // Header.GetComponent<TextMesh>().text = head;
    }

   // public void changeheader(string head) {
        
     //   Header = GameObject.FindGameObjectWithTag("Header");
       // Header.GetComponent<TextMesh>().text = head;
   // }
}