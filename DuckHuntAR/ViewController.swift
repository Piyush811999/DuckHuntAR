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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var Score: UILabel!
    
    
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // collision detection
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        addTargetNodes()
        
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

            nodeDirection  = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
            node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.5,0,0), asImpulse: true)
        
        node.physicsBody?.applyForce(nodeDirection , asImpulse: true)
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
    
    func addTargetNodes(){
        for _ in 1...20 {
            
            var node = SCNNode()
                let scene = SCNScene(named: "art.scnassets/duck.dae")
                node = (scene?.rootNode.childNode(withName: "Cube", recursively: true)!)!
                node.scale = SCNVector3(0.5,0.5,0.5)
                node.name = "Duck"

            
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            //place randomly, within thresholds
            node.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -10, max: 10))
            
            //rotate
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let movingAction : SCNAction = SCNAction.move(by: SCNVector3(0, 0.1, 0), duration: 10000)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            node.runAction(movingAction)
            
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
            }else{
               score+=1
            }
            
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                self.Score.text = String(self.score)
            }
            
            let  explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
            contact.nodeB.addParticleSystem(explosion!)
        }
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let duck = CollisionCategory(rawValue: 1 << 1) // 00..10
}

