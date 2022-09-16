//
//  GameScene.swift
//  GameExample
//
//  Created by Sinem Ünal on 6.09.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    var bird2 = SKSpriteNode()
    var bird = SKSpriteNode()
    var box1 = SKSpriteNode()
    var box2 = SKSpriteNode()
    var box3 = SKSpriteNode()
    var box4 = SKSpriteNode()
    var box5 = SKSpriteNode()
    var boxArray = [SKSpriteNode]()
    var originalPosition : CGPoint?
    
    var score = 0
    var scoreLabel = SKLabelNode()
    
   
    var gameStarted = false
    var birdThrowCheck = false
    
    
    enum ColliderType : UInt32{
        case Bird = 1
        case Box = 2
    }
    
    
    
    override func didMove(to view: SKView) {
        

        boxArray = [box1, box2, box3, box4, box5]
    
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsWorld.contactDelegate = self // contactları algılama opsiyonu olacak
        
        
        
        bird = childNode(withName: "bird") as! SKSpriteNode //tasarımda oluşturulan bird burada tanımlandı.
        let birdTexture  = SKTexture(imageNamed: "bird")
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 10)
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true //fiziksel simülasyonlardan etkilenecek mi?
        bird.physicsBody?.mass = 0.25
        originalPosition = bird.position
        
        //çarpışma
        bird.physicsBody?.contactTestBitMask = ColliderType.Box.rawValue
        bird.physicsBody?.categoryBitMask = ColliderType.Box.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Box.rawValue
        

        let boxTexture  = SKTexture(imageNamed: "brick")
        let size = CGSize(width: boxTexture.size().width / 5, height: boxTexture.size().height / 5)
        for i in 0..<(boxArray.count) {
            let box = childNode(withName:"box\(i+1)") as! SKSpriteNode
            box.physicsBody = SKPhysicsBody(rectangleOf: size)
            box.physicsBody?.affectedByGravity = true
            box.physicsBody?.isDynamic = true
            box.physicsBody?.allowsRotation = true
            box.physicsBody?.mass = 0.4
            box.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
        
        }
        
        
        
        //Label
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height / 4)
        scoreLabel.zPosition = 2
        self.addChild(scoreLabel)
     
     
    }
    //oluşturulduğumuz kategorilerden bir şey birbirine değerse çağrılacak
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.collisionBitMask == ColliderType.Bird.rawValue || contact.bodyB.collisionBitMask == ColliderType.Bird.rawValue {
            
            score += 1
            scoreLabel.text = String(score)
            
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
       
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    //Dokunma başladı
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.birdPosition(touches:touches)
    
    }
  
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.birdPosition(touches:touches)
      
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.birdThrowCheck = true
        self.birdPosition(touches:touches)
      
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let birdPhysicsBody = bird.physicsBody {
            if birdPhysicsBody.velocity.dx <= 0.1 && birdPhysicsBody.velocity.dy <= 0.1 &&
                birdPhysicsBody.angularVelocity <= 0.1 && gameStarted == true {
                self.reload()
                
            }
        }
    }
    

    
    func reload(){
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.angularVelocity = 0
        bird.zPosition = 1
        bird.position = originalPosition!
        gameStarted = false
        birdThrowCheck = false
        score = 0
        scoreLabel.text = String(score)
    }
    
    func birdPosition(touches: Set<UITouch>) {
        if gameStarted == false {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self) // dokunulan yer
                let touchNodes = nodes(at: touchLocation) //dokunulan yerdeki node
                
                if touchNodes.isEmpty == false {
                    for node in touchNodes {
                        
                        if let sprite = node as? SKSpriteNode {
                            if sprite == bird {
                                bird.position = touchLocation
                                if birdThrowCheck == true {
                                    self.birdThrow(touches: touches)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func birdThrow(touches: Set<UITouch>){
        let touchLocation = self.getTouchLocation(touches: touches)
        let dx = -(touchLocation.x - originalPosition!.x)
        let dy = -(touchLocation.y - originalPosition!.y)
        
        let impulse = CGVector(dx: dx, dy: dy)
        bird.physicsBody?.applyImpulse(impulse)
        bird.physicsBody?.affectedByGravity = true
        gameStarted = true
    }
    
    func getTouchLocation(touches: Set<UITouch>) -> CGPoint{
        if let touch = touches.first {
            return touch.location(in: self)
            
        }
        return CGPoint(x: 0, y:0)
    }
    
    
    
    
}
