# MalaTang

## Project Description

In the context of today's rapid technological advancement, mixed reality technology has opened a new gateway connecting the virtual world to the real one. Our project crafts an advanced digital collaborative workspace within this realm for educational settings. This not only allows users to integrate their real environment and objects with virtual functionalities but also offers them an interactive stage.

## Prerequisites

* Xcode 15.0 (or later)
* iOS devices(one Macbook,one/two ipad/iphone) running iOS 13.2 (or later)
* Cable to connect the mac to the iOS device
* python 3.12.0 (or later)

## Guidelines for use

1.Download whole codebase from [this link](https://github.com/SuperWBY/3801-Project-MLT).

(step 2-5 are needed only for networking)
2.Open Terminal on Macbook and use the 'ifconfig' command to obtain the local network IP address
  (en0)."

3.Use Xcode to open the whole folder and change IP address to your local IP address in
  ViewController.swift, line 12

4.open server.py and change the the IP address in line 5

5.open Terminal again，navigate to the directory that contains server.py using command ‘cd (path 
  to server.py)', then use command 'python/python3 server.py' to start server  

6.Connecting your devices(ipad or iphone) to your MacBook with a data cable.

7.CLick the "Run" button or press "command + R" to build the app on your device

8.Provisioning Profile error may occur, choose a team and insert a unique bundle identifier will 
  fix this error

9.Open **Setting**, go to **General** -> **VPN & Device Management**, and trust the application.

10.Open the application and allow **using camara** to scan the workspace, after model shown, you 
   can add tags, move, rotate and zoom in or out on model. Also, Model positions and tag 
   content can be synchronized between two devices

## Open Source Used

The framework comes from [ARCampus](https://github.com/ElisaKazan/ARCampus/tree/master) written by [@Elisa Kazan](https://twitter.com/ElisaKazan), it contains basic AR function, what we changed are following functions:

* AppDelegate.swift: We delete the irrelevant part and only keep useful part
* ViewController.swift: We delete the irrelevant part, and add our own function: WebSocketManager, add gestures to respond user's operation, connect other files to ensure functionality
* Chat.swift: This file implements functions on communication between users. 
* ViewController+Delegate.swift: We delete the irrelevant part and only keep useful part

## Screenshots about the application

<center>
<figure>
<img src="https://github.com/SuperWBY/3801-Project-MLT/blob/main/Screenshots/example_2.jpg?raw=true" alt="Example Image" width="50%" style="display:block;">

<img src="https://github.com/SuperWBY/3801-Project-MLT/blob/main/Screenshots/example_3.jpg?raw=true" alt="Example Image" width="50%" style="display:block;">
 </figure>
</center>

<img src="https://github.com/SuperWBY/3801-Project-MLT/blob/main/Screenshots/example_6.jpg?raw=true" alt="Example Image" width="400" style="display:block; margin:auto;">



