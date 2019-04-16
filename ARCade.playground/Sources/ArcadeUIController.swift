/**
 
 This is a file to assist in generating computationally intensive data
 structures for the main playground.
 
 **/


import SpriteKit
import UIKit
import Foundation
import SceneKit
import PlaygroundSupport
import ARKit




public class ArcadeViewController : UIViewController, ARSCNViewDelegate {
    
    //Boxes are representative of the pixels in the display
    private var boxes = [CAShapeLayer]()
    
    //Detected planes
    private var detectedNodes = [SCNNode]()
    
    //Time delay for the loop
    public var timeDelay = 0.0005;
    
    //Parent layer that holds the boxes
    private var parentLayer = CAShapeLayer()
    
    //Chip8 machine interface, creates the chip8 machine
    private var chip8 = Chip8()
    
    //View that has the arcade machine and elements.
    private var currentView = ARSCNView()
    
    //Indicator if the arcade has been placed in the world
    private var didPlaceArcade = false
    
    //Button 1 text
    private let BUTTON_1_TEXT = "LEFT"
    
    //Button 2 text
    private let BUTTON_2_TEXT = "CENTER"
    
    //Button 3 text
    private let BUTTON_3_TEXT = "RIGHT"
    
    //UILabel for instructions
    private var pressButtonUI = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    
    /**
        Configures settings for the ARSCNView
    */
    private func initView(view: ARSCNView) {
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = true
        view.automaticallyUpdatesLighting = true //Last thing added.
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        view.delegate = self
        view.debugOptions = [.showFeaturePoints]
        view.session.run(arConfig, options: [.removeExistingAnchors, .resetTracking])
    }
    
    /**
        Update the CAShapeLayers with a color for on/off pixels
    */
    public func updateScreen() {
        var count = 0
        for i in self.chip8.displayArray() {
            if i == 0 {
                boxes[count].fillColor = UIColor.black.cgColor
                
            } else {
                boxes[count].fillColor = UIColor.green.cgColor
            }
            count += 1
        }
    }
    
    /**
        This initScreenLayer function takes the defined parentLayer and boxes and initializes them
    */
    public func initScreenLayer(){
        
        self.parentLayer.bounds = CGRect(x: 0.0, y: 0.0, width: 640, height: 320)
        
        let startingX = 320.0
        let startingY = 160.0 - 5.0
        let size = 5.0
        
        
        var count = 0
        for length in 0...31 {
            for width in 0...63 {
                let box = CAShapeLayer()
                
                let xLoc = startingX + (Double(width) * 5.0)
                let yLoc = startingY - (Double(length) * 5.0)
                
                box.path = CGPath(rect: CGRect(x: xLoc, y: yLoc, width: size , height: size), transform: nil)
                
                box.fillColor = UIColor.black.cgColor
                box.borderColor = UIColor.black.cgColor
                
                
                self.parentLayer.addSublayer(box)
                self.boxes.append(box)
                //screenScene.addChild(box)
                count += 1
            }
        }
        
        self.parentLayer.backgroundColor = UIColor.green.cgColor

    }
    
    
    /**
     This creates a user interface on your screen to interact with
     the arcade controls.  This interface was created because I tried physical
     buttons but they just were not as fun to use.
    */
    public func createUI(){
        
        let screenSize = UIScreen.main.bounds
        print(screenSize.height)
        print(screenSize.width)
        
        let yLevel = screenSize.height/2 + 70
        
        pressButtonUI = UILabel(frame: CGRect(x: screenSize.width/2 - 200, y: screenSize.height/2, width: 600, height: 50))
        pressButtonUI.text = "Find a surface and tap screen to place arcade"
        pressButtonUI.textColor = UIColor.white
        
        
        let gameButton = UIButton()
        gameButton.setTitle(BUTTON_1_TEXT, for: .normal)
        gameButton.setTitleColor(UIColor.black, for: .normal)
        gameButton.backgroundColor = UIColor.white
        gameButton.layer.borderColor = UIColor.black.cgColor
        gameButton.layer.borderWidth = 0.5
        gameButton.layer.cornerRadius = 10.0
        gameButton.frame = CGRect(x: 0, y: yLevel, width: 100, height: 100)
        //gameButton.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvent)
        gameButton.addTarget(self, action: #selector(self.buttonPressed(sender:)), for: .touchDown)
        gameButton.addTarget(self, action: #selector(self.buttonUp(sender:)), for: .touchUpInside)
        gameButton.addTarget(self, action: #selector(self.buttonUp(sender:)), for: .touchUpOutside)
        
        let gameButton2 = UIButton()
        gameButton2.setTitle(BUTTON_2_TEXT, for: .normal)
        gameButton2.setTitleColor(UIColor.black, for: .normal)
        gameButton2.backgroundColor = UIColor.white
        gameButton2.layer.borderColor = UIColor.black.cgColor
        gameButton2.layer.borderWidth = 0.5
        gameButton2.layer.cornerRadius = 10.0
        gameButton2.frame = CGRect(x: 100, y: yLevel, width: 100, height: 100)
        //gameButton.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvent)
        gameButton2.addTarget(self, action: #selector(self.buttonPressed(sender:)), for: .touchDown)
        gameButton2.addTarget(self, action: #selector(self.buttonUp(sender:)), for: .touchUpInside)
        gameButton2.addTarget(self, action: #selector(self.buttonUp(sender:)), for: .touchUpOutside)
        
        let gameButton3 = UIButton()
        gameButton3.setTitle(BUTTON_3_TEXT, for: .normal)
        gameButton3.setTitleColor(UIColor.black, for: .normal)
        gameButton3.backgroundColor = UIColor.white
        gameButton3.layer.borderColor = UIColor.black.cgColor
        gameButton3.layer.borderWidth = 0.5
        gameButton3.layer.cornerRadius = 10.0
        gameButton3.frame = CGRect(x: 200, y: yLevel, width: 100, height: 100)
        //gameButton.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvent)
        gameButton3.addTarget(self, action: #selector(self.buttonPressed(sender:)), for: .touchDown)
        gameButton3.addTarget(self, action: #selector(self.buttonUp(sender:)), for: .touchUpInside)
        gameButton3.addTarget(self, action: #selector(self.buttonUp(sender:)), for: .touchUpOutside)
        
        self.currentView.addSubview(gameButton)
        self.currentView.addSubview(gameButton2)
        self.currentView.addSubview(gameButton3)
        self.currentView.addSubview(pressButtonUI)
        
        
    }
    
    /**
     This function handles button presses and tells the chip8 device
     that it has a certain key that was pressed.
    */
    @objc func buttonPressed(sender: UIButton!){
        if sender.title(for: .normal) == BUTTON_1_TEXT {
            print("Press Button1")
            if didPlaceArcade {
                chip8.setKeyDown(key: "q")
            }
            sender.alpha = 0.5
        } else if sender.title(for: .normal) == BUTTON_2_TEXT {
            print("Press Button2")
            if didPlaceArcade {
                chip8.setKeyDown(key: "w")
            }
            sender.alpha = 0.5
        } else if sender.title(for: .normal) == BUTTON_3_TEXT {
            print("Press Button3")
            if didPlaceArcade {
                chip8.setKeyDown(key: "e")
            }
            sender.alpha = 0.5
        }
    }
    
    /**
     This function is similar to buttonPressed except it is for the
     release of a key.
    */
    @objc func buttonUp(sender: UIButton!){
        //Reason for this is that operation sometimes happens faster then chip8 opcodes.
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
            if sender.title(for: .normal) == self.BUTTON_1_TEXT {
                print("Release Button1")
                if self.didPlaceArcade {
                    self.chip8.setKeyUp(key: "q")
                }
                sender.alpha = 1.0
            } else if sender.title(for: .normal) == self.BUTTON_2_TEXT {
                print("Release Button2")
                if self.didPlaceArcade {
                    self.chip8.setKeyUp(key: "w")
                }
                sender.alpha = 1.0
            } else if sender.title(for: .normal) == self.BUTTON_3_TEXT {
                print("Release Button3")
                if self.didPlaceArcade {
                    self.chip8.setKeyUp(key: "e")
                }
                sender.alpha = 1.0
            }
            
        }
    }
    

    /**
     Loads our ARSCNView and does other initialization
    */
    public override func loadView() {
        
        //Create the scene for which the objects will go
        let scene = SCNScene()
        
        //Create the ar view, configure it, and set the scene.
        let view = ARSCNView()
        initView(view: view)
        view.scene = scene
        self.currentView = view
        
        //UIConfig
        self.createUI()
        
        
        //Camera config
        let camera = view.pointOfView!.camera!
        camera.fStop = 2.8
        camera.zFar = 700
        let cameraNode = view.pointOfView!
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x:0.0, y:0.0, z:0.0)
        scene.rootNode.addChildNode(cameraNode)
        
        //Adding tap gestures to the screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addArcadeToSceneView(withGestureRecognizer:)))
        self.currentView.addGestureRecognizer(tapGesture)
        
        
        self.view = view
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsDisplay()
        //Loading our game, which has been picked out in this demo.
        chip8.loadGame()
        
        //Emulate a clock cycle by putting it on a repeating timer :)
        Timer.scheduledTimer(withTimeInterval: timeDelay, repeats: true) { timer in
            if self.didPlaceArcade {
                self.chip8.emulationCycle()
                if self.chip8.shouldDraw() {
                    self.updateScreen()
                }
            }
        }
        
        
    }
    
    
    /**
        Once the tap occurs it will add our arcade to the scene.
    */
    @objc func addArcadeToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if self.didPlaceArcade == false {
            let tapLocation = recognizer.location(in: self.currentView)
            let hitTestResults = self.currentView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.columns
            let x = Double(translation.3.x)
            let y = Double(translation.3.y)
            let z = Double(translation.3.z)
            
            let url = Bundle.main.url(forResource: "arcadeMachine", withExtension: "scn")!
            let arcadeMachine = SCNReferenceNode(url: url)!
            arcadeMachine.load()
            arcadeMachine.position = SCNVector3(x,y,z)
            arcadeMachine.scale = SCNVector3(0.2, 0.2, 0.2)
            
            //Similar scaling to the screen res of 64 x 32
            let box = SCNPlane(width: 0.64, height: 0.32)
            self.initScreenLayer()
            
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.diffuse.contents = self.parentLayer
            box.materials = [material]
            
            let boxNode = SCNNode(geometry: box)
            boxNode.position = SCNVector3(x-0.05, y+0.43, z-0.10)
            boxNode.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(-10.0))
            boxNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(90.0))
            
            
            self.currentView.scene.rootNode.addChildNode(boxNode)
            self.currentView.scene.rootNode.addChildNode(arcadeMachine)
            self.didPlaceArcade = true
            self.pressButtonUI.text = ""
            self.currentView.debugOptions = []
            for var scnNode in self.detectedNodes {
                scnNode.removeFromParentNode()
            }
            self.detectedNodes = [SCNNode]()
            
            
        }
    }
    
    
    /**
     Function used for surface detection and dispalying information
    */
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if didPlaceArcade == false {
            guard let planeAnchor = anchor as?  ARPlaneAnchor,
                let planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNPlane
                else { return }
            
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            plane.width = width
            plane.height = height
            
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x, y, z)
        }
    }
    
    
    
    /**
     Function used for surface detection and dispalying information
     */
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if didPlaceArcade == false {
            guard let planeAnc = anchor as? ARPlaneAnchor else { return }
            
            let width = CGFloat(planeAnc.extent.x)
            let height = CGFloat(planeAnc.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            let planeNode = SCNNode(geometry: plane)
            
            let x = CGFloat(planeAnc.center.x)
            let y = CGFloat(planeAnc.center.y)
            let z = CGFloat(planeAnc.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi/2
            
            node.addChildNode(planeNode)
            detectedNodes.append(node)
        }
    }
    
}

