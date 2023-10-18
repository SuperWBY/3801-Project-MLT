import UIKit

/// View that displays building information
class Chat: UIView, UITableViewDataSource, UITableViewDelegate {
    var tableData = ["Insert your username:"]
    var modeltype = ""
    var username = ""
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aa", for: indexPath)
               cell.textLabel?.text = tableData[indexPath.row]
        tableView.separatorStyle = .none
               return cell
    }
    
    
   /// @IBOutlet var botton: UIButton!
    @IBOutlet var input: UITextField!
    @IBOutlet var tableView: UITableView!

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let message = input.text {
            if username == ""  {
                username = message
                WebSocketManager.shared.sendMessage("tag;\(modeltype);\(username)")
                WebSocketManager.shared.sendMessage("tag;\(modeltype);welcome, \(username), happy to add tag")
            } else{
                
                
                // 添加消息到数据源
                //tableData.append("\(username)\(message)")
                // 刷新表格视图以显示新消息
                // tableView.reloadData()
                // 清空输入框
                
                
                WebSocketManager.shared.sendMessage("tag;\(modeltype);\(username):\(message)")}
            input.text = ""
            
        }
    }
    
    func updateBuildingInfo(tags:[String], model: String) {
        tableData = tags
        modeltype = model
        tableView.reloadData()
        let indexPath = IndexPath(row: tableData.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
      //  print("update once")
    }
    // 其他 Chat 类的实现部分
}
