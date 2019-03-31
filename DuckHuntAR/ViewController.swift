//
//  ViewController.swift
//  DuckHuntAR
//
//  Created by Piyush Makwana on 30/03/19.
//  Copyright © 2019 Piyush Makwana. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var Score: UILabel!
    
    @IBOutlet weak var tierLable: UILabel!
    
    var score = 0
    var stage = 0
    var player: AVAudioPlayer?
    
    /// timer
    var seconds = 40
    var timer = Timer()
    var isTimerRunning = false
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds == 0 {
            timer.invalidate()
            gameOver()
        }else{
            seconds -= 1
            tierLable.text = "\(seconds)"
        }
        
    }
    
    func resetTimer(){
        timer.invalidate()
        seconds = 40
        tierLable.text = "\(seconds)"
    }
    
    func gameOver(){
        //store the score in UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: "score")
        //go back to the Home View Controller
        playAudio(name: "Game Over.mp3")
        self.dismiss(animated: true, completion: nil)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // collision detection
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        playAudio(name: "Intro.mp3")
        
        
//        addTargetNodes()
        addDuckBylevel()
        
        runTimer()
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
 
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR coordinates are in meters
       
        let bulletDirection  = SCNVector3(direction.x*8,direction.y*8,direction.z*8)
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
    }
    
    func createBullet()->SCNNode{
        let node = Bullet()
        return node
    }
    

    
    // fire bullet in direction camera is facing
    func fireBullet(){
        var node = SCNNode()
        node = createBullet()
        let (direction, position) = self.getUserVector()
        node.position = position
        var nodeDirection = SCNVector3()

            nodeDirection  = SCNVector3(direction.x*50,direction.y*50,direction.z*50)
            node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.5,0,0), asImpulse: true)
        
        node.physicsBody?.applyForce(nodeDirection , asImpulse: true)
        playSound(sound: "Bullet", format: "mp3")
        sceneView.scene.rootNode.addChildNode(node)
    }

    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            // 4x4  transform matrix describing camera in world space
            let mat = SCNMatrix4(frame.camera.transform)
            // orientation of camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // location of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    
    
    @objc func addDuckBylevel() {
        var duckNode = SCNNode()
        var goldenDuckNode = SCNNode()
        
        //normal duck
        var scene = SCNScene(named: "art.scnassets/bird_open.dae")
        duckNode = (scene?.rootNode.childNode(withName: "Cube_003", recursively: true)!)!
        duckNode.scale = SCNVector3(0.5,0.5,0.4)
        duckNode.name = "Duck"
        duckNode.isHidden = false
        
        //golden duck
        scene = SCNScene(named: "art.scnassets/duck.dae")
        goldenDuckNode = (scene?.rootNode.childNode(withName: "Cube", recursively: true)!)!
        goldenDuckNode.scale = SCNVector3(0.5,0.5,0.4)
        goldenDuckNode.name = "GoldenDuck"
        goldenDuckNode.isHidden = false
        
        // random position
        duckNode.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -20, max: -7))

        duckNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        duckNode.physicsBody?.isAffectedByGravity = false
        
        //this thing need to change
        duckNode.physicsBody?.applyForce(SCNVector3Make(0, 0, Float(arc4random_uniform(2) + 2) ), asImpulse: true)
        duckNode.physicsBody?.categoryBitMask = CollisionCategory.duck.rawValue
        duckNode.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        
        playAudio(name: "Duck Quack.mp3")
        
        sceneView.scene.rootNode.addChildNode(duckNode)
        
        let duckDisappearAction = SCNAction.sequence([SCNAction.wait(duration: 10),SCNAction.fadeOut(duration: 1), SCNAction.removeFromParentNode()])
        duckNode.runAction(duckDisappearAction)
        
        
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addDuckBylevel), userInfo: nil, repeats: false)
      
    }
    
    func addTargetNodes(){
        for _ in 1...20 {
            
            var node = SCNNode()
                let scene = SCNScene(named: "art.scnassets/bird_open.dae")
                node = (scene?.rootNode.childNode(withName: "Cube_003", recursively: true)!)!
                node.scale = SCNVector3(0.5,0.5,0.4)
                node.name = "Duck"

            
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            //place randomly, within thresholds
            node.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -10, max: 10))
            
            
            //rotate
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
//            let movingAction : SCNAction = SCNAction.move(by: SCNVector3(0, 0.1, 0), duration: 10000)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
//            node.runAction(movingAction)
            
            //for collision detection
            node.physicsBody?.categoryBitMask = CollisionCategory.duck.rawValue
            node.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
            
            //add to scene
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.duck.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.duck.rawValue {
            
            if (contact.nodeA.name! == "Duck" || contact.nodeB.name! == "Duck") {
               score+=5
            }
            
            DispatchQueue.main.async {
                contact.nodeB.removeFromParentNode()
                contact.nodeA.physicsBody?.isAffectedByGravity = false
                contact.nodeA.physicsBody?.applyForce(SCNVector3Make(0, 0, 0 ), asImpulse: true)
//                let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
//                let forever = SCNAction.repeatForever(action)
//                contact.nodeA.runAction(forever)
                self.playAudio(name: "Gun Shot.mp3")
                self.playAudio(name: "duck_hunt.wav")
                let duckDisappearAction = SCNAction.sequence([SCNAction.wait(duration: 1),SCNAction.fadeOut(duration: 1), SCNAction.removeFromParentNode()])
                contact.nodeA.runAction(duckDisappearAction)
                self.dogAppears(number: 1, position: contact.nodeA.position)
                
                
                
                
                
                
                self.Score.text = String(self.score)
            }
            
            let  explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
            contact.nodeB.addParticleSystem(explosion!)
        }
    }
    
    func dogAppears(number: Int, position: SCNVector3) {
        if number == 2 {
            var node = SCNNode()
            let scene = SCNScene(named: "art.scnassets/dog_double_bird.dae")
            node = (scene?.rootNode.childNode(withName: "Cube_007", recursively: true)!)!
            node.scale = SCNVector3(0.5,0.5,0.4)
            node.name = "Dog_2"
            
            node.physicsBody?.isAffectedByGravity = false
            node.position = SCNVector3(position.x,position.y,position.z + 3)
            node.physicsBody?.applyForce(SCNVector3Make(0, 1, 0), asImpulse: true)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            sceneView.scene.rootNode.addChildNode(node)
            let dogDisappearAction = SCNAction.sequence([SCNAction.wait(duration: 3),SCNAction.fadeOut(duration: 1), SCNAction.removeFromParentNode()])
            node.runAction(dogDisappearAction)
            
            
        }else{
            var node = SCNNode()
            let scene = SCNScene(named: "art.scnassets/dog_single_bird.dae")
            node = (scene?.rootNode.childNode(withName: "Cube_005", recursively: false)!)!
            node.scale = SCNVector3(0.5,0.5,0.5)
            node.name = "Dog_1"
            
            node.physicsBody?.isAffectedByGravity = false
            node.position = position
            //node.physicsBody?.applyForce(SCNVector3Make(0, 0, 0), asImpulse: true)
            node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            
            let dogDisappearAction = SCNAction.sequence([SCNAction.wait(duration: 1),SCNAction.fadeOut(duration: 2), SCNAction.removeFromParentNode()])
            node.runAction(dogDisappearAction)
            sceneView.scene.rootNode.addChildNode(node)
            
            
            
        }
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    
    func playSound(sound : String, format: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: format) else { return }
        do {
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try! AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func playBackgroundMusic(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "Intro.mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        
        audioNode.addAudioPlayer(audioPlayer)
        
        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
    func playAudio(name: String) {
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: name)!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        
        audioNode.addAudioPlayer(audioPlayer)
        
        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let duck = CollisionCategory(rawValue: 1 << 1) // 00..10
}


// TODO
// ADD LEVELS
// dOGGGO
// ADD GOLDEN DUCK
// FIX MOVMENT
// MUSIC
// PLANE FLOOR DETECTION

