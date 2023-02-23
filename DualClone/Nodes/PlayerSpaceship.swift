

import CoreGraphics
import SpriteKit



class PlayerSpaceship: Spaceship {
    
    fileprivate let engineBurstEmitter = SKEmitterNode(fileNamed: "PlayerSpaceshipEngineBurst")!
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init() {
        let size = CGSize(width: 64, height: 50)
        
        self.init(texture: SKTexture(imageNamed: ImageName.PlayerSpaceship.rawValue),
                  color: UIColor.brown,
                  size: size)
        
        name = NSStringFromClass(PlayerSpaceship.self)
        
        configureCollisions()
    }
    
    // MARK: - Configuration
    
    fileprivate func configureCollisions() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.allowsRotation = false
        
        physicsBody!.categoryBitMask = CategoryBitmask.playerSpaceship.rawValue
        physicsBody!.collisionBitMask =
            CategoryBitmask.enemyMissile.rawValue |
            CategoryBitmask.screenBounds.rawValue
            
        
        physicsBody!.contactTestBitMask =
            CategoryBitmask.playerSpaceship.rawValue |
            CategoryBitmask.enemyMissile.rawValue
    }
    
    // MARK: - Special actions
    
    func launchMissile() {
        // Create a missile
        let missile = Missile.playerMissile()
        missile.position = CGPoint(x: position.x, y: frame.maxY + 35)
        missile.zPosition = zPosition - 1
        
        // Place it in the scene
        scene!.addChild(missile)
        
        // Make it move
        let velocity: CGFloat = 1600.0
        let moveDuration = scene!.size.height / velocity
        let missileEndPosition = CGPoint(x: position.x, y: position.y + scene!.size.height)
        
        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
      
        missile.run(SKAction.sequence([moveAction, removeAction]))
        
        // Play sound
        if (position.y < scene!.frame.height){
            scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))}
    }
    func launchMissile2() {
        // Create a missile
        let missile = Missile.playerMissile()
        missile.texture = SKTexture(imageNamed:ImageName.Missile2.rawValue)
        missile.position = CGPoint(x: position.x, y: frame.maxY + 35)
        missile.zPosition = zPosition - 1
        
        // Place it in the scene
        scene!.addChild(missile)
        
        // Make it move
        let velocity: CGFloat = 1600.0
        let moveDuration = scene!.size.height / velocity
        let missileEndPosition = CGPoint(x: position.x, y: position.y + scene!.size.height)
        
        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
      
        missile.run(SKAction.sequence([moveAction, removeAction]))
        
        // Play sound
        if (position.y < scene!.frame.height){
            scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))}
    }
}
