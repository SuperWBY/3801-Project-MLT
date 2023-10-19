//
//  Chat.swift
//
//  Created by Team MalaTang
//

import UIKit

/// UIview that displays model information
class Chat: UIView, UITableViewDataSource, UITableViewDelegate {
    var tableData = ["Insert your username:"]
    var modeltype = ""
    var username = ""
    
    ///UItableview protocol, this one return how many cells included in UItableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    ///UItableview protocal, this one return cells in table view according to one cell prefab
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aa", for: indexPath)
               cell.textLabel?.text = tableData[indexPath.row]
        tableView.separatorStyle = .none
               return cell
    }
    
    
   
    @IBOutlet var input: UITextField!
    @IBOutlet var tableView: UITableView!

    ///triggered when button get pressed, it will clean the Textfield and upload message to server
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let message = input.text {
            if username == ""  {
                username = message
                WebSocketManager.shared.sendMessage("tag;\(modeltype);\(username)")
                WebSocketManager.shared.sendMessage("tag;\(modeltype);welcome, \(username), happy to add tag")
            } else{
                WebSocketManager.shared.sendMessage("tag;\(modeltype);\(username):\(message)")}
            input.text = ""
            
        }
    }
    
    ///update tableView when the tags content get changed
    func updateBuildingInfo(tags:[String], model: String) {
        tableData = tags
        modeltype = model
        tableView.reloadData()
        let indexPath = IndexPath(row: tableData.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
      //  print("update once")
    }
}
