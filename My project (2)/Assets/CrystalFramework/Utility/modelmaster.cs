using UnityEngine;
using UnityEngine.UI;
using System.IO;

public class modelmaster : MonoBehaviour
{

    [SerializeField] GameObject buttonPrefab; // 按钮的预制体
    public Transform buttonParent;   // 按钮的父级对象，通常是一个UI面板
    public string photoFolderPath;   

    private void Start()
    {
        //C:\\Users\\15719\\Desktop\\ssss\\3801-Project-MLT\\My project (2)\\Assets\\images\\modelimage
        buttonParent = GameObject.Find("modelmaster").transform;
        photoFolderPath = "C:\\Users\\15719\\Desktop\\ssss\\3801-Project-MLT\\My project (2)\\Assets\\images\\modelimage";
        if (Directory.Exists(photoFolderPath))
        {
            // 获取文件夹中的所有图片文件
            string[] photoFiles = Directory.GetFiles(photoFolderPath, "*.png"); // 这里只选择了PNG格式的图片，你可以根据需要更改扩展名

            foreach (string filePath in photoFiles)
            {
                // 创建按钮
                GameObject button = Instantiate(buttonPrefab, buttonParent);
                
                // 获取按钮上的RawImage组件
                RawImage rawImage = button.GetComponentInChildren<RawImage>();

                // 从文件加载纹理并赋值给按钮上的RawImage组件
                byte[] fileData = File.ReadAllBytes(filePath);
                Texture2D texture = new Texture2D(2, 2); // 根据实际图片大小设置纹理大小
                texture.LoadImage(fileData);
                rawImage.texture = texture;

                // 可以在按钮上添加点击事件，以便在点击时执行相应操作
                button.GetComponent<Button>().onClick.AddListener(() => OnButtonClick(filePath));
            }
        }
        else
        {
            Debug.LogError("指定的文件夹不存在：" + photoFolderPath);
        }
    }

    // 按钮点击事件的处理函数
    private void OnButtonClick(string filePath)
    {
        Debug.Log("点击了按钮，文件路径：" + filePath);
        // 在这里可以执行打开图片、处理图片等操作
    }
}

