//
//  GameViewController.swift
//  DrawScape
//
//  Created by Drew Paul on 10/12/18.
//  Copyright © 2018 Drew Paul. All rights reserved.
//

import ARKit
import LBTAComponents
import ColorSlider

class GameViewController: UIViewController, ARSCNViewDelegate {
    
    var previousPoint: SCNVector3?
    var buttonHighlighted = false
    var lockz = Float(0.0)
    var planeArea = Float(0.0)
    var paintColor = UIColor.red
    var brushSize = Float(0.0)
    var undoNum = Int(1)
    var changeNum = false
    var updatePlane = true
    
    var planeWidth = Float(0.0)
    var planeHeight = Float(0.0)
    var planeOrigin = SCNVector3Zero
    
    var leftXBound = Float(0.0)
    var rightXBound = Float(0.0)
    var bottomYBound = Float(0.0)
    var topYBound = Float(0.0)
    
    var leftXConstraint = Float(0.0)
    var rightXConstraint = Float(0.0)
    var bottomYConstraint = Float(0.0)
    var topYConstraint = Float(0.0)
    
    var globalPlane = SCNVector3Zero
    
    let arView: ARSCNView = {
        let view = ARSCNView()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
    
    @objc func changedColor(slider: ColorSlider) {
        paintColor = slider.color
    }
    
    @objc func changedSlider(_ sender: UISlider) {
        brushSize = Float(sender.value)
    }
    
    let buttonWidth = UIScreen.main.bounds.size.width * 0.16
    
    var plusButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage(named: "PlusButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.7))
        button.addTarget(self, action: #selector(handlePlusButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    @objc func handlePlusButtonTapped() {
        print("Tapped on plus button!!")
        //        addNode()
        
        //        var doesEarthNodeExistInScene = false
        //        arView.scene.rootNode.enumerateChildNodes{ (node, _) in
        //            if node.name == "earth" {
        //                doesEarthNodeExistInScene = true
        //            }
        //        }
        //        if !doesEarthNodeExistInScene {
        //            addEarth()
        //        }
    }
    
    var minusButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage(named: "MinusButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.7))
        button.addTarget(self, action: #selector(handleMinusButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    @objc func handleMinusButtonTapped() {
        print("Tapped on minus button!!")
        if(undoNum > 1){
            undoNum = undoNum - 1
        }
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if (node.name == String(undoNum)){
                node.removeFromParentNode()
            }
        }
    }
    
    var checkButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage(named: "CheckButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.7))
        button.addTarget(self, action: #selector(handleCheckButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    @objc func handleCheckButtonTapped() {
        print("Tapped on check button!!")
        
        updatePlane = false
    }
    
    /*
     var resetButton: UIButton = {
     var button = UIButton(type: .system)
     button.setImage(UIImage(named: "ResetButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
     button.tintColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.7))
     button.addTarget(self, action: #selector(handleResetButtonTapped), for: .touchUpInside)
     button.layer.zPosition = 1
     button.imageView?.contentMode = .scaleAspectFill
     return button
     }()
     
     @objc func handleResetButtonTapped() {
     print("Tapped on reset button!!")
     resetScene()
     }
     */
    
    let configuration = ARWorldTrackingConfiguration()
    
    /*
     var distanceLabel: UILabel = {
     let label = UILabel()
     label.font = UIFont.boldSystemFont(ofSize: 14)
     label.textColor = UIColor.black
     label.text = "Distance:"
     return label
     }()
     
     let xLabel: UILabel = {
     let label = UILabel()
     label.font = UIFont.boldSystemFont(ofSize: 14)
     label.textColor = UIColor.red
     label.text = "x:"
     return label
     }()
     
     let yLabel: UILabel = {
     let label = UILabel()
     label.font = UIFont.boldSystemFont(ofSize: 14)
     label.textColor = UIColor.green
     label.text = "y:"
     return label
     }()
     
     let zLabel: UILabel = {
     let label = UILabel()
     label.font = UIFont.boldSystemFont(ofSize: 14)
     label.textColor = UIColor.blue
     label.text = "z:"
     return label
     }()
     */
    let centerImageView: UIImageView = {
        let view = UIImageView()
        view.image = (UIImage(named: "Center"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    var startingPositionNode: SCNNode?
    var endingPositionNode: SCNNode?
    let cameraRelativePosition = SCNVector3(0,0,-0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        configuration.planeDetection = .vertical
        
        arView.session.run(configuration, options: [])
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        //   arView.showsStatistics = true
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        arView.autoenablesDefaultLighting = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        colorSlider.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.92, y: UIScreen.main.bounds.size.height * 0.05, width: 15, height: 150)
        colorSlider.addTarget(self, action: #selector(changedColor(slider:)), for: .valueChanged)
        view.addSubview(colorSlider)
        
        let brushSlider: UISlider = UISlider(frame: CGRect(x: UIScreen.main.bounds.size.width * 0.591, y: UIScreen.main.bounds.size.height * 0.55, width: 260, height: 15))
        brushSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        brushSlider.isContinuous = true
        brushSlider.minimumValue = 0.3
        brushSlider.maximumValue = 1.0
        brushSlider.value = 0.65
        brushSlider.maximumValueImage = (UIImage(named: "BigBrush3"))
        brushSlider.minimumValueImage = (UIImage(named: "SmallBrush3"))
        brushSlider.addTarget(self, action: #selector(GameViewController.changedSlider(_:)), for: .valueChanged)
        self.view.addSubview(brushSlider)
        
        brushSize = brushSlider.value
    
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func setupViews(){
        //        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //        arView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        //        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //        arView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        view.addSubview(arView)
        // arView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        arView.fillSuperview()
        
        view.addSubview(plusButton)
        plusButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 30, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonWidth)
        plusButton.anchorCenterXToSuperview()
        
        view.addSubview(minusButton)
        minusButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 30, rightConstant: 30, widthConstant: buttonWidth, heightConstant: buttonWidth)
        
        view.addSubview(checkButton)
        checkButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 30, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonWidth)
        
        
        /*
         view.addSubview(resetButton)
         resetButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 24, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonWidth)
         resetButton.anchorCenterXToSuperview()
         */
        
        /*
         view.addSubview(distanceLabel)
         distanceLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 24, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
         
         view.addSubview(xLabel)
         view.addSubview(yLabel)
         view.addSubview(zLabel)
         
         xLabel.anchor(distanceLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
         yLabel.anchor(xLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
         zLabel.anchor(yLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
         */
        view.addSubview(centerImageView)
        centerImageView.anchorCenterSuperview()
        centerImageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: UIScreen.main.bounds.size.width * 0.05, heightConstant: UIScreen.main.bounds.size.width * 0.05)
    }
    
    func addNode() {
        /* adding a bunch of random shapes */
        let shapeNode = SCNNode()
        //      boxNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.0002)
        //    shapeNode.geometry = SCNCapsule(capRadius: 0.05, height: 0.20)
        //    shapeNode.geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.05, height: 0.15)
        shapeNode.geometry = SCNTorus(ringRadius: 0.10, pipeRadius: 0.02)
        shapeNode.geometry?.firstMaterial?.diffuse.contents = "Material"
        shapeNode.position = SCNVector3(Float.random(-0.5, max: 0.5), Float.random(-0.5, max: 0.5), Float.random(-0.5, max: 0.5))
        shapeNode.name = "node"
        arView.scene.rootNode.addChildNode(shapeNode)
    }
    
    func removeAllBoxes() {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if (node.name == "node"){
                node.removeFromParentNode()
            }
        }
    }
    
    func resetScene() {
        arView.session.pause()
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if (node.name == "node"){
                node.removeFromParentNode()
            }
        }
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
        let floor = SCNNode()
        floor.name = "floor"
        floor.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        floor.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        floor.geometry?.firstMaterial?.diffuse.contents = "Blue"
        floor.geometry?.firstMaterial?.isDoubleSided = true
        floor.opacity = 0.60
        floor.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        return floor
    }
    
    func removeNode(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if (node.name == named){
                node.removeFromParentNode()
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        if(updatePlane == true){
            print("New horizontal plane anchor found with extent: ", anchorPlane.extent)
            let floor = createFloor(anchor: anchorPlane)
            node.addChildNode(floor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if(updatePlane == true){
            guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
            print("Plane horizontal anchor updated with extent: ", anchorPlane.extent)
            removeNode(named: "floor")
            let floor = createFloor(anchor: anchorPlane)
            lockz = anchorPlane.transform.columns.3.z + 0.03
            //+ anchorPlane.transform.columns.2.z
            planeWidth = anchorPlane.extent.x
            planeHeight = anchorPlane.extent.z  //y b/c plane is rotated so it needs z
            
            planeOrigin = SCNVector3(anchorPlane.center.x, 0, anchorPlane.center.z)

            node.addChildNode(floor)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if(updatePlane == true){
            guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
            print("Plane horizontal anchor removed with extent: ", anchorPlane.extent)
            removeNode(named: "floor")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if startingPositionNode != nil && endingPositionNode != nil {
            return
        }
        /*
         
         guard let xDistance = Service.distance3(fromStartingPositionNode: startingPositionNode, onView: arView, cameraRelativePosition: cameraRelativePosition)?.x else {return}
         guard let yDistance = Service.distance3(fromStartingPositionNode: startingPositionNode, onView: arView, cameraRelativePosition: cameraRelativePosition)?.y else {return}
         guard let zDistance = Service.distance3(fromStartingPositionNode: startingPositionNode, onView: arView, cameraRelativePosition: cameraRelativePosition)?.z else {return}
         
         DispatchQueue.main.async {
         self.xLabel.text = String(format: "x: %.2f", xDistance) + "m"
         self.yLabel.text = String(format: "y: %.2f", yDistance) + "m"
         self.zLabel.text = String(format: "z: %.2f", zDistance) + "m"
         self.distanceLabel.text = String(format: "Distance: %.2f", Service.distance(x: xDistance, y: yDistance, z: zDistance)) + "m"
         self.buttonHighlighted = self.plusButton.isHighlighted
         }
         */
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        //        let tappedView = sender.view as! SCNView
        //        let touchLocation = sender.location(in: tappedView)
        //        let hitTest = tappedView.hitTest(touchLocation, options: nil)
        //        if !hitTest.isEmpty {
        //            let result = hitTest.first!
        //            let name =  result.node.name
        //            let geometry = result.node.geometry
        //            print("Tapped \(String(describing: name)) with \(String(describing: geometry)): ")
        //        }
        /*
         if startingPositionNode != nil && endingPositionNode != nil {
         startingPositionNode?.removeFromParentNode()
         endingPositionNode?.removeFromParentNode()
         startingPositionNode = nil
         endingPositionNode = nil
         } else if startingPositionNode != nil && endingPositionNode == nil {
         let sphere = SCNNode(geometry: SCNSphere(radius: 0.002))
         sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.red
         Service.addChildNode(sphere, toNode: arView.scene.rootNode, inView: arView, cameraRelativePosition: cameraRelativePosition)
         endingPositionNode = sphere
         } else if startingPositionNode == nil && endingPositionNode == nil {
         let sphere = SCNNode(geometry: SCNSphere(radius: 0.002))
         sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
         Service.addChildNode(sphere, toNode: arView.scene.rootNode, inView: arView, cameraRelativePosition: cameraRelativePosition)
         startingPositionNode = sphere
         }
         */
    }
    
    func addEarth(){
        /*
         let earthNode = SCNNode()
         earthNode.name = "earth"
         earthNode.geometry = SCNSphere(radius: 0.2)
         earthNode.geometry?.firstMaterial?.diffuse.contents = "EarthDiffuse"
         earthNode.geometry?.firstMaterial?.specular.contents = "EarthSpecular"
         earthNode.geometry?.firstMaterial?.emission.contents = "EarthEmission"
         earthNode.geometry?.firstMaterial?.normal.contents = "EarthNormal"
         earthNode.position = SCNVector3(0, 0, -0.5)
         arView.scene.rootNode.addChildNode(earthNode)
         
         let rotate = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 15)
         let rotateForever = SCNAction.repeatForever(rotate)
         earthNode.runAction(rotateForever)
         */
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let cameraPoint = arView.pointOfView else {return}
        
        let cameraTransform = cameraPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
        
        leftXBound = planeOrigin.x - (0.5 * planeWidth)
        rightXBound = planeOrigin.x + (0.5 * planeWidth)
        
        bottomYBound = planeOrigin.z - (0.5 * planeHeight)
        topYBound = planeOrigin.z + (0.5 * planeHeight)
        
        DispatchQueue.main.async {
            if self.plusButton.isHighlighted {
                let sphere = SCNNode()
                sphere.name = String(self.undoNum)
                sphere.geometry = SCNSphere(radius: CGFloat(0.025 * self.brushSize))
                sphere.geometry?.firstMaterial?.diffuse.contents = self.paintColor
                sphere.position = SCNVector3(x: cameraPosition.x,
                                             y: cameraPosition.y, z: self.lockz)
                
                // check if it's in the bounds of the painting
                if(cameraPosition.x >= self.leftXBound && cameraPosition.x <= self.rightXBound && cameraPosition.y >= self.bottomYBound && cameraPosition.y <= self.topYBound) {
                    self.arView.scene.rootNode.addChildNode(sphere)
                }
                self.changeNum = true
            }
            else{
                if(self.changeNum == true){
                    self.undoNum = self.undoNum + 1
                    self.changeNum = false
                }
            }
        }
        print("x: ", planeOrigin.x)
        print("y: ", planeOrigin.z)
    }
}
