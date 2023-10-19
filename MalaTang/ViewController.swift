import UIKit
import RealityKit
import ARKit

import Foundation
import Starscream

//Some codes were from “https://github.com/ElisaKazan/ARCampus/tree/master”
//establish network connection
class WebSocketManager: WebSocketDelegate {
    weak var viewController: ViewController!
    private init() {
        let socketURL = URL(string: "ws://192.168.68.61:3000")!//the ip of the server
        socket = WebSocket(request: URLRequest(url: socketURL))
        socket.delegate = self
        socket.connect()
    }
 
    /// This method is called when the WebSocket receives an event.
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .text(let text):
            NotificationCenter.default.post(name: Notification.Name("NewMessageReceived"), object: text)
        default:
            break
        }
    }
    
    static let shared = WebSocketManager()
    var socket: WebSocket!
    
    ///inform network working
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected to WebSocket server")
    }

    ///inform network did disconnect
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let error = error {
            print("Disconnected from WebSocket server with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from WebSocket server")
        }
    }
    
    /// This method is called when the WebSocket receives an event.
    ///
    /// - Parameters:
    ///   - message: the message sent to server
    func sendMessage(_ message: String) {
        do {
            try socket.write(string: message)
        } catch let error {
            print("Error sending message: \(error)")
        }
    }
}

///manage the view shown screen
class ViewController: UIViewController {
    var SA = ["Insert your username:"]//store the tags attached on model, and there is three models so three arrays
    var AT = ["Insert your username:"]
    var PA = ["Insert your username:"]
   
    /// The Arview
    @IBOutlet var arView: ARView!
    
    /// The view that provides instructions for getting a horizontal plane
    @IBOutlet weak var coachingOverlayView: ARCoachingOverlayView!
    
    /// The view that displays tags added on model
    @IBOutlet weak var tags: Chat!
    
    /// The anchor for the DioramaScene from the Reality Composer file，and reality composer are used to build a small plane in Arview to show models, and models are also premade in reality composer
    var dioramaAnchorEntity: Experience.DioramaScene?
    
    /// The plane anchor found by coaching overlay
    var horizontalPlaneAnchor: ARAnchor?
    
    /// A toggle for print statements
    var debugMode = true
    
    /// Booleans for state
    var contentIsLoaded = false
    var planeAnchorIsFound = false
    
    ///ensure the arview successfully load，there are many things need to be done before view successfully load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tags.tableView.dataSource=tags.self
        tags.tableView.delegate=tags.self
        WebSocketManager.shared.sendMessage("hi")//like a handshake, establish connection to server
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessage(_:)), name: Notification.Name("NewMessageReceived"), object: nil)
        //set up a notifier to notice view to update, when the client receive message from server
    }
    
    /// This method is called when receive notification from notifier in view, when client receive message from server, it will run this function
    /// to update model position and tag content.
    @objc func handleNewMessage(_ notification: Notification) {
        if let text = notification.object as? String {
        
        let separatedParts = text.components(separatedBy: ";")
        let type = separatedParts[0]
           ///if the message receive is about model position
            if type == "Server received: modelposition" {
                ///basicly large part below just transfer message received from server to the correct format and get userful message like entity name, the updated model position
                let Entityname = separatedParts[1]
                let Entityposition = separatedParts[2]
                var simd3Coordinate: SIMD3<Float>?
                if let range = Entityposition.range(of: "(") {
                    let startIndex = Entityposition.index(after: range.lowerBound)
                    if let endIndex = Entityposition.range(of: ")", options: .backwards)?.lowerBound {
                        let valuesString = Entityposition[startIndex..<endIndex].replacingOccurrences(of: " ", with: "")
                        let values = valuesString.split(separator: ",").compactMap { Float($0) }
                        
                        if values.count == 3 {
                            simd3Coordinate = SIMD3<Float>(values[0], values[1], values[2])
                            
                        } else {
                            print("error")
                        }
                        ///simply change position of model, accroding to correct format of model position and model name
                        let select = arView.scene.findEntity(named: Entityname)
                        select?.transform.translation = simd3Coordinate!
                    }
                }
            }
            
            /// if received message is about tag
            if type == "Server received: tag"    {
                let Entityname = separatedParts[1]
                let tag = separatedParts[2]
                print(tag)
                var tagss = [String]()
                
                ///attach tag to specific model according to model name
                if tags.username != "" {
                    if Entityname == "SA" {
                        SA.append(tag)
                        tagss = SA
                    } else if Entityname == "AT" {
                        AT.append(tag)
                        tagss = AT
                    } else {
                        PA.append(tag)
                        tagss = PA
                    }
                    ///update tags attached to specific model
                    tags.updateBuildingInfo(tags: tagss,model: Entityname)
                }
            }
        }
    }
    
    /// setup Arview
    func setupView() {
        /// Hide building information view
        self.tags.isHidden = true
        
        /// Create ARWorldTrackingConfiguration for horizontal planes
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arConfiguration.isCollaborationEnabled = false
            
        /// Include AR debug options
        arView.debugOptions = [.showAnchorGeometry,
                               .showAnchorOrigins]
            
        /// Run the view's session
        arView.session.run(arConfiguration, options: [])
            
        /// Loads the diorama scene from the RC file  asynchronously
        loadDioramaScene()
        
        /// Instructions for getting a nice horizontal plane
        presentCoachingOverlay()
    }
    
    /// This method to handle when screen get touched.
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        /// Location that user tapped
        let tapLocation = sender.location(in: arView)
        
        /// Find entity at tapped location and check if valid building (no entity tapped, invalid building code)
        guard let buildingEntity = arView.entity(at: tapLocation), isBuilding(entity: buildingEntity)  else {
            print("Error: Invalid entity found.")
            hidetagsAndArrow()
            return
        }
        
        ///show the tags when model be tapped
        let model = buildingEntity.name
        var tagss = [String]()
        if model == "SA" {
            tagss = SA
        } else if model == "AT" {
            tagss = AT
        } else {
            tagss = PA
        }
        tags.updateBuildingInfo(tags: tagss,model: model)
        
        
        /// Move arrow to selected building
        self.highlightSelectedBuilding(buildingEntity: buildingEntity)
        
        /// Update building info overlay view and display
        self.tags.isHidden = false
    }
    
    /// This method to handle when screen get touched.
    @IBAction func scalePiece(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let selectedEntity = arView.entity(at: gestureRecognizer.location(in: arView)),
              isBuilding(entity: selectedEntity) else {
            return
        }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            // Get the scaling of the selected building entity
            var scale = selectedEntity.transform.scale
            // Updated scaling based on the proportions of the pinch gesture
            scale *= Float(gestureRecognizer.scale)

            // Updated scaling of building entities
            selectedEntity.transform.scale = scale
            gestureRecognizer.scale = 1.0
        }
    }
    
    /// This method is used to move model
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let selectedEntity = arView.entity(at: sender.location(in: arView)),
              isBuilding(entity: selectedEntity) else {
            return
        }

        let translation = sender.translation(in: arView)

        if sender.state == .began || sender.state == .changed || sender.state == .ended {
            // get the current position of model
            var currentPosition = selectedEntity.transform.translation
            //Update the current position based on the movement of the pan gesture
            currentPosition.x += Float(translation.x) / Float(arView.frame.size.width)
            currentPosition.y -= Float(translation.y) / Float(arView.frame.size.height)
            
            // Update the model position
            selectedEntity.transform.translation = currentPosition
            sender.setTranslation(CGPoint.zero, in: arView)
            if sender.state == .ended {
                //when model stop move, it will send the model position to server
                WebSocketManager.shared.sendMessage("modelposition;\(selectedEntity.name);\(String(describing: currentPosition))")
            }
        }
    }
    
    /// This method is used to rotated model
    @IBAction func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
        guard let selectedEntity = arView.entity(at: gestureRecognizer.location(in: arView)),
              isBuilding(entity: selectedEntity) else {
            return
        }

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            // Rotation of objects
            var rotation = selectedEntity.transform.rotation
            let rotationAngle = Float(gestureRecognizer.rotation)
            
            // Increased rotation speed
            let rotationSpeedMultiplier: Float = 2.0
            rotation *= simd_quatf(angle: rotationSpeedMultiplier * rotationAngle, axis: [0, 1, 0])

            selectedEntity.transform.rotation = rotation
            gestureRecognizer.rotation = 0.0
        }
    }

    
    /// Check if entity is a valid model
    func isBuilding(entity: Entity) -> Bool {
        return entity.name == "SA" || entity.name == "AT" || entity.name == "PA"
    }
    
    /// Loops over all ArrowBlocks and hides them
    func hideAllArrowBlocks(diorama: Experience.DioramaScene) {
        for level1ChildEntity in diorama.children {
            for level2ChildEntity in level1ChildEntity.children {
                for buildingEntity in level2ChildEntity.children {
                    if debugMode {
                        print("Building: \(buildingEntity.name)")
                    }
                    guard let arrowBlockEntity = buildingEntity.findEntity(named: Strings.arrowBlock) else {
                        print("Error: Cannot find ArrowBlock for \(buildingEntity.name) entity")
                        continue
                    }
                    /// Instead of disabling the arrowBlock, disable its ModelEntity
                    /// This hides the visual model but keeps the model enabled
                    guard let childModelEntity = arrowBlockEntity.findEntity(named: "simpBld_root") else {
                        print("Error: Cannot find simpBld_root entity.")
                        return
                    }
                    childModelEntity.isEnabled = false
                }
            }
        }
    }
    
    
    
    /// This method is used to hide tags UI
    func hidetagsAndArrow() {
        /// Hide Building Overlay
        self.tags.isHidden = true
        
        /// Hide arrow
        guard let dioramaAnchor = self.dioramaAnchorEntity else {
            print(Strings.nilDioramaAnchorEntityError)
            return
        }

        guard let arrowEntity = dioramaAnchor.arrow else {
            print(Strings.nilArrowEntityError)
            return
        }
        
        arrowEntity.isEnabled = false
    }
    
    /// Move the arrow entity to show which building has been selected
    func highlightSelectedBuilding(buildingEntity: Entity) {
        
        guard let dioramaAnchor = self.dioramaAnchorEntity else {
            print(Strings.nilDioramaAnchorEntityError)
            return
        }
        
        guard let arrowEntity = dioramaAnchor.arrow else {
            print(Strings.nilArrowEntityError)
            return
        }

        /// Show arrow
        arrowEntity.isEnabled = true
        
        /// The ArrowBlock of the building
        guard let arrowBlockEntity = buildingEntity.findEntity(named: Strings.arrowBlock) else {
            print("Error: Cannot find ArrowBlock for tapped building.")
            return
        }
        
        if debugMode {
            print("Highlighting building \(buildingEntity.name)...")
            print("Arrow Start position: \(arrowEntity.position)")
            print("ArrowBlock Position: \(arrowBlockEntity.position)")
        }
        
        /// Move the arrow to the selected building by setting the ArrowBlock as the parent
        /// This prevents any race conditions with the spin behaviour in RC which modifies the arrow's transform
        arrowEntity.setParent(arrowBlockEntity)

        if debugMode {
            print("Arrow End position: \(arrowEntity.position)")
            print("--")
        }
    }
    
    /// Prevent device from sleeping during idle coaching (coaching phase may take a while and typically expects no touch events)
    func presentCoachingOverlay() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        coachingOverlayView.session = arView.session
        /// The VC must also act as a view delegate for the coachingOverlayView
        coachingOverlayView.delegate = self
        coachingOverlayView.goal = .horizontalPlane
        coachingOverlayView.activatesAutomatically = false
        self.coachingOverlayView.setActive(true, animated: true)
    }
    
    /// remove Coaching Overlay
    func removeCoachingOverlay() {
        UIApplication.shared.isIdleTimerDisabled = false
        
        coachingOverlayView.delegate = nil
        coachingOverlayView.setActive(false, animated: false)
        coachingOverlayView.removeFromSuperview()
    }
    
    ///place diorama view in the screen
    func placeDioramaInWorld() {
        /// Check that both conditions are met
        if !contentIsLoaded || !planeAnchorIsFound {
            print("Error: At least one condition is not met.")
        }
        
        guard let planeAnchor = horizontalPlaneAnchor, let dioramaAnchor = dioramaAnchorEntity else {
            print("Error: dioramaAnchorEntity or horizontalPlaneAnchor returned nil.")
            return
        }
        
        /// Create anchor entity from plane anchor
        let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)
        
        /// Scale anchor
        if debugMode {
            print("AnchorEntity Scale Before: \(dioramaAnchor.scale)")
        }
        
        let scale:Float = 0.25
        dioramaAnchor.setScale([scale, scale, scale], relativeTo: planeAnchorEntity)
        
        if debugMode {
            print("AnchorEntity Scale After: \(dioramaAnchor.scale)")
        }
        
        /// Add anchor to scene
        self.arView.scene.addAnchor(dioramaAnchor)
        
        if debugMode {
            //print("Anchors: \(self.arView.scene.anchors)")
        }
        
        // Gesture: tap, pinch, pan, and rotate.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scalePiece(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)

    }
    
    /// Loads DioramaScene from Reality Composer file
    func loadDioramaScene() {
        Experience.loadDioramaSceneAsync { [weak self] result in
            /// This is the callback for when loading the diorama has completed
            switch result {
            case .success(let loadedDioramaAnchorEntity):
                guard let self = self else { return }
                
                if self.debugMode {
                    print("Diorama has successfully finished loading.")
                }

                /// Update state
                self.contentIsLoaded = true
                
                /// Hide all arrow block entities
                self.hideAllArrowBlocks(diorama: loadedDioramaAnchorEntity)
                
                /// Hide the arrow entity
                guard let arrowEntity = loadedDioramaAnchorEntity.arrow else {
                    print(Strings.nilArrowEntityError)
                    return
                }
                
                arrowEntity.isEnabled = false
                
                /// Update dioramaAnchorEntity and place diorama in real world
                if self.dioramaAnchorEntity == nil {
                    self.dioramaAnchorEntity = loadedDioramaAnchorEntity
                                                  
                    /// The case where plane anchor is found first
                    if self.contentIsLoaded && self.planeAnchorIsFound {
                        self.placeDioramaInWorld()
                    }
                }
            case .failure(let error):
                fatalError("Error: Unable to load the scene with error: \(error.localizedDescription)")
            }
        }
    }
}
