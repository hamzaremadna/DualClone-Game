

import SpriteKit
import MultipeerConnectivity
import CoreMotion

protocol GameSceneDelegate: class {
    func didTapMainMenuButton(in gameScene: GameScene)
    func playerDidLose(withScore score: Int, in gameScene:GameScene)
}

class GameScene: SKScene{
    
    private struct Constants {
        static let hudControlMargin: CGFloat = 20.0
        static let scoresNodeBottomMargin: CGFloat = 26.0
        static let fireButtonBottomMargin: CGFloat = 40.0
        static let joystickMaximumRadius: CGFloat = 40.0
        static let explosionEmmiterFileName = "Explosion"
        static let explosionEmmiterFileName2 = "Explosion2"
    }
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    fileprivate let redInverse = SKEmitterNode(fileNamed: "RedInverse")!
    fileprivate let bleuInverse = SKEmitterNode(fileNamed: "BlueInverse")!
    fileprivate let engine = SKEmitterNode(fileNamed: "Red")!
    fileprivate let engineBurstEmitter = SKEmitterNode(fileNamed: "PlayerSpaceshipEngineBurst")!


    private var background: SKSpriteNode?
    private var playerSpaceship = PlayerSpaceship()
    private var joystick: Joystick?
    private var u = true
    private var k = true
    private var q = false
    private var o = false
    private var h = true
    private var w = 0
    private var timer: Timer?
    private var player = PlayerSpaceship()
    private var fireButton: Button?
    private var label=SKLabelNode(text: "")
    private var menuButton: Button?
    private let lifeIndicator = LifeIndicator(texture: SKTexture(imageNamed: ImageName.LifeBall.rawValue))
    private let ammoIndicator = Ammo(texture: SKTexture(imageNamed: ImageName.LifeBall.rawValue))
    var appDelegate:AppDelegate!
    var motionManager = CMMotionManager()

    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        let defaults = UserDefaults.standard
         w = defaults.integer(forKey: "spaceship")
        if(w==2){
            playerSpaceship.texture = SKTexture(imageNamed: ImageName.EnemySpaceship.rawValue)
            engine.position = CGPoint(x: playerSpaceship.position.x, y: playerSpaceship.position.y - playerSpaceship.size.width/2 - 5.0)
            playerSpaceship.addChild(engine)
        }else{
            engineBurstEmitter.position = CGPoint(x: 0.0, y: -playerSpaceship.size.width/2 - 5.0)
            playerSpaceship.addChild(engineBurstEmitter)
        }

        scaleMode = SKSceneScaleMode.resizeFill
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate.MPC.delegate = self
        appDelegate.MPC.serviceAdvertiser.startAdvertisingPeer()
        scene?.backgroundColor = UIColor.black
        label.position = CGPoint(x: frame.width/2, y: frame.height/2)
        label.fontSize = 50
        label.text = "Waiting for a player"
        label.zPosition = 2
        label.color = UIColor.white
        addChild(label)
configure()
    }
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.isMultipleTouchEnabled = true
    }
}



extension GameScene {
    
    private func configurePhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        let a = CGPoint(x: frame.maxX, y: frame.height*2)
        let b = CGPoint(x: frame.maxX, y: frame.minY)
        let d = CGPoint(x: frame.minX, y: frame.minY)
        let f = CGPoint(x: frame.minX, y: frame.height*2)
        let body1=SKPhysicsBody(edgeFrom: a, to: b)
        let bod = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 30), center: CGPoint(x:frame.width/2,y:frame.minY))
        let bod2 = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 30), center: CGPoint(x:frame.width/2,y:frame.height*2))
        let body3=SKPhysicsBody(edgeFrom: d, to: f)
        let body = SKPhysicsBody(bodies: [body1,bod,body3,bod2])
        physicsBody = body
        physicsBody?.isDynamic = false
        physicsBody!.categoryBitMask = CategoryBitmask.screenBounds.rawValue
        physicsBody!.collisionBitMask = CategoryBitmask.playerSpaceship.rawValue | CategoryBitmask.enemySpaceship.rawValue
    
        
    }
    
    private func configurePlayerSpaceship() {
        // Position
        
        
        playerSpaceship.position = CGPoint(x: frame.width/2,
                                           y: 150)
        // Life points
        playerSpaceship.ammonumber = 10
        playerSpaceship.lifePoints = 100
        playerSpaceship.didRunOutOfLifePointsEventHandler = playerDidRunOutOfLifePointsEventHandler()
        playerSpaceship.didRunOutOfAmmoEventHandler = playerDidRunOutOfAmmoEventHandler()
        
        player.removeAllChildren()
        let body = SKPhysicsBody(rectangleOf: player.size)
        body.usesPreciseCollisionDetection = true
        body.allowsRotation = false
        
        body.categoryBitMask = CategoryBitmask.playerSpaceship.rawValue
        body.collisionBitMask =
            CategoryBitmask.playerMissile.rawValue |
            CategoryBitmask.screenBounds.rawValue
        
        body.contactTestBitMask =
            CategoryBitmask.playerSpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue
        player.physicsBody = body
        player.zPosition = playerSpaceship.zPosition
        if(w==2){
            bleuInverse.position = CGPoint(x: 0.0, y: +self.player.size.width/2 + 5.0)
            player.addChild(bleuInverse)
                player.texture = SKTexture(imageNamed: ImageName.PlayerInverse1.rawValue)
        }
        else{
        redInverse.position = CGPoint(x: 0.0, y: +self.player.size.width/2 + 5.0)
        player.addChild(redInverse)
            player.texture = SKTexture(imageNamed: ImageName.PlayerInverse2.rawValue)}
        // Add it to the scene
        addChild(playerSpaceship)
    }
    
    
    private func configureJoystick() {
        joystick = Joystick(maximumRadius: Constants.joystickMaximumRadius,
                            stickImageNamed: ImageName.JoystickStick.rawValue,
                            baseImageNamed: ImageName.JoystickBase.rawValue)
        // Position
        joystick!.position = CGPoint(x: joystick!.size.width,
                                     y: joystick!.size.height)
        // Handler that gets called on joystick move
        joystick!.updateHandler = { [weak self] joystickTranslation in
            self?.updatePlayerSpaceshipPosition(with: joystickTranslation)
            
            
        }
        
        // Add it to the scene
        addChild(joystick!)
    }
    
    
    
    private func configure(){
        configureBackground()
        configurePlayerSpaceship()
        configurePhysics()
        configureHUD()
        scaleMode = SKSceneScaleMode.fill
    }
    private func configureFireButton() {
        fireButton = Button(normalImageNamed: ImageName.FireButtonNormal.rawValue,
                            selectedImageNamed: ImageName.FireButtonSelected.rawValue)
        fireButton!.position = CGPoint(x: frame.width - fireButton!.frame.width - Constants.hudControlMargin,
                                       y: fireButton!.frame.height/2 + Constants.fireButtonBottomMargin)
        fireButton!.touchUpInsideEventHandler = { [weak self] in
            if(self!.w==2){ self?.playerSpaceship.launchMissile2()}else{
                self?.playerSpaceship.launchMissile()}
            self!.shoot()
            let a = self!.playerSpaceship.position.x
            let b = self!.playerSpaceship.position.y
            self!.appDelegate.MPC.send(text: "shot \(a) \(b)")
        }
        addChild(fireButton!)
    }
    
    
    
    private func configureMenuButton() {
        menuButton = Button(normalImageNamed: ImageName.ShowMenuButtonNormal.rawValue,
                            selectedImageNamed: ImageName.ShowMenuButtonSelected.rawValue)
        menuButton!.position = CGPoint(x: frame.width - menuButton!.frame.width/2 - 2.0,
                                       y: frame.height - menuButton!.frame.height/2)
        // Touch handler
        menuButton!.touchUpInsideEventHandler = { [weak self] in
            guard let strongSelf = self else { return }
            
            self!.appDelegate.MPC.session.disconnect()
            strongSelf.gameSceneDelegate?.didTapMainMenuButton(in: strongSelf)

        }
        // Add it to the scene
        addChild(menuButton!)
    }
    
    private func configureLifeIndicator() {
        // Position
        lifeIndicator.position = CGPoint(x: joystick!.frame.maxX + 2.5 * joystick!.joystickRadius,
                                         y: joystick!.frame.minY - joystick!.joystickRadius)
        // Life points
        lifeIndicator.setLifePoints(playerSpaceship.lifePoints, animated: false)
        
        ammoIndicator.position = fireButton!.position
        ammoIndicator.zPosition = zPosition - 1
        ammoIndicator.size = fireButton!.size
        // Life points
        ammoIndicator.setAmmonumber(playerSpaceship.ammonumber, animated: false)
        // Add it to the scene
        addChild(lifeIndicator)
        addChild(ammoIndicator)
        
    }
    
    
    private func configureBackground() {
        // Create background node
        let backgroundNode = SKSpriteNode(imageNamed: ImageName.GameBackgroundPhone.rawValue)
        backgroundNode.size = size
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundNode.zPosition = -1000
        
        // Add background to the scene
        addChild(backgroundNode)
        background = backgroundNode
    }

    
    
    private func updatePlayerSpaceshipPosition(with joystickTranslation: CGPoint) {
        let translationConstant: CGFloat = 25.0
        playerSpaceship.position.x += translationConstant * joystickTranslation.x
        playerSpaceship.position.y += translationConstant * joystickTranslation.y
        
        if(playerSpaceship.position.y>self.frame.maxY){
            q=true
            appDelegate.MPC.send(text: "\(translationConstant * joystickTranslation.x) \(translationConstant * joystickTranslation.y) \(playerSpaceship.position.x)")
        }else{appDelegate.MPC.send(text: "del")
            q=false
        }
        
    }
    
    private func configureHUD() {
        
        configureJoystick()
        configureFireButton()
        configureMenuButton()
        configureLifeIndicator()
    
    }
    
}


// MARK: - Collision detection

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Get collision type
        guard let collisionType = self.collisionType(for: contact) else { return }
        
        switch collisionType {
            
            
            
        case .enemyMissilePlayerSpaceship:
            let missile: Missile
            if contact.bodyA.node is Missile {
                missile = contact.bodyA.node as! Missile
            } else {
                missile = contact.bodyB.node as! Missile
            }
            missile.removeFromParent()
            appDelegate.MPC.send(text: "shoot")
            
        case .playerMissileEnemySpaceship:
            let missile: Missile
            if contact.bodyA.node is Missile {
                missile = contact.bodyA.node as! Missile
            } else {
                missile = contact.bodyB.node as! Missile
            }
            handleCollision(between: missile, and: playerSpaceship)
            
        }
    }
    
    private func collisionType(for contact: SKPhysicsContact!) -> CollisionType? {
        guard
            let categoryBitmaskBodyA = CategoryBitmask(rawValue: contact.bodyA.categoryBitMask),
            let categoryBitmaskBodyB = CategoryBitmask(rawValue: contact.bodyB.categoryBitMask) else {
                return nil
        }
        
        switch (categoryBitmaskBodyA, categoryBitmaskBodyB) {
        // Player missile - enemy spaceship
        case (.playerSpaceship, .enemyMissile),
             (.enemyMissile, .playerSpaceship):
            return .playerMissileEnemySpaceship
            
        case (.playerSpaceship, .playerMissile),
             (.playerMissile, .playerSpaceship):
            return .enemyMissilePlayerSpaceship
            
            
        default:
            return nil
        }
    }
    
}

// MARK: - Collision handling

extension GameScene {
    
    private func handleCollision(between enemyMissile: Missile,and playerSpaceship: PlayerSpaceship) {
        enemyMissile.removeFromParent()
        // Update score
        // Update life points
        modifyLifePoints(of: playerSpaceship,
                         by: LifePointsValue.playerMissileHitEnemySpaceship.rawValue)
        let shake = SKAction.shake(initialPosition: playerSpaceship.position, duration: 0.3)
        playerSpaceship.run(shake)
    }
    private func shoot() {
        modifyAmmonumber(of: playerSpaceship,
                         by: AmmonumberValue.playershoot.rawValue)    }
    
}


extension GameScene {
 
    private func modifyLifePoints(of playerSpaceship: PlayerSpaceship, by value: Int) {
        playerSpaceship.lifePoints += value
        lifeIndicator.setLifePoints(playerSpaceship.lifePoints, animated: false)
        
        
        // Add a color blend for a short moment to indicate the change of health
        let color: UIColor = value > 0 ? .green : .red
        playerSpaceship.run(blendColorAction(with: color))
    }
    private func modifyAmmonumber(of playerSpaceship: PlayerSpaceship, by value: Int) {
        playerSpaceship.ammonumber += value
        ammoIndicator.setAmmonumber(playerSpaceship.ammonumber, animated: false)
    }
    private func blendColorAction(with color: UIColor) -> SKAction {
        let colorizeAction = SKAction.colorize(with: UIColor.red,
                                               colorBlendFactor: 0.7,
                                               duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0,
                                                 duration: 0.2)
        return SKAction.sequence([colorizeAction, uncolorizeAction])
    }
    
    
    
    private func playerDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        return { [weak self] _ in
            guard let strongSelf = self else { return }
            if(self!.playerSpaceship.position.y<self!.frame.height){
                self!.destroySpaceship(self?.playerSpaceship)}
            else{
                
                self!.appDelegate.MPC.send(text: "up")
            }
            self!.appDelegate.MPC.send(text: "ok")
            var a = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                a+=1
                if a == 3 {
                    strongSelf.gameSceneDelegate?.playerDidLose(withScore:self!.playerSpaceship.lifePoints,
                                                                in: strongSelf)
                    timer.invalidate()
                }
            }
            timer.fire()
        }
    }
    private func playerDidRunOutOfAmmoEventHandler() -> DidRunOutOfAmmoEventHandler {
        return { [weak self] _ in
            guard self != nil else { return }
            self!.fireButton?.isEnabled = false
            
            self!.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                
                let missil = Missile.playerMissile()
                if(self!.w==2){missil.texture = SKTexture(imageNamed:ImageName.Missile2.rawValue)}
                missil.position.x = self!.fireButton!.position.x
                missil.position.y = self!.frame.maxY
                missil.physicsBody?.categoryBitMask = CategoryBitmask.playerSpaceship.rawValue
                
                self?.scene!.addChild(missil)
                
                let velocity: CGFloat = 1600.0
                let moveDuration = (self?.scene!.size.height)! / velocity
                let missileEndPosition = CGPoint(x: self!.fireButton!.position.x, y: self!.fireButton!.frame.maxY)
                let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
                let removeAction = SKAction.removeFromParent()
                missil.run(SKAction.sequence([moveAction, removeAction]))
                self!.playerSpaceship.ammonumber += 1
                self?.ammoIndicator.setAmmonumber(self!.playerSpaceship.ammonumber, animated: false)
                if self!.playerSpaceship.ammonumber == 10 {
                    self!.fireButton?.isEnabled = true
                    timer.invalidate()
                }
            }
            self!.timer!.fire()
        }
    }
    
    private func destroySpaceship(_ spaceship: Spaceship!) {
        // Create an explosion
        self.fireButton?.isEnabled = false
        var explosionEmitter = SKEmitterNode()
        if(w==2){        if(k==true){
                explosionEmitter = SKEmitterNode(fileNamed: Constants.explosionEmmiterFileName2)!}
            else{
                explosionEmitter = SKEmitterNode(fileNamed: Constants.explosionEmmiterFileName)!
            }
        }else{
        if(k==true){
            explosionEmitter = SKEmitterNode(fileNamed: Constants.explosionEmmiterFileName)!}
        else{
            explosionEmitter = SKEmitterNode(fileNamed: Constants.explosionEmmiterFileName2)!
            }}
        explosionEmitter.position.x = spaceship.position.x - spaceship.size.width/2
        explosionEmitter.position.y = spaceship.position.y
        explosionEmitter.zPosition = spaceship.zPosition + 1
        addChild(explosionEmitter)
        explosionEmitter.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()]))
        spaceship.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.removeFromParent()]))
        scene!.run(SKAction.playSoundFileNamed(SoundName.Explosion.rawValue, waitForCompletion: false))
    }
    
}
extension SKAction {
    class func shake(initialPosition:CGPoint, duration:Float, amplitudeX:Int = 12, amplitudeY:Int = 3) -> SKAction {
        let startingX = initialPosition.x
        let startingY = initialPosition.y
        let numberOfShakes = duration / 0.015
        var actionsArray:[SKAction] = []
        for index in 1...Int(numberOfShakes) {
            let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            actionsArray.append(SKAction.move(to: CGPoint(x: newXPos, y: newYPos), duration: 0.015))
        }
        actionsArray.append(SKAction.move(to: initialPosition, duration: 0.015))
        return SKAction.sequence(actionsArray)
    }
}
extension GameScene: SendTextServiceDelegate {
    
    func connectedDevicesChanged(manager: SendTextService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.label.isHidden = true
            switch connectedDevices {
            case ["iPhone 7"],["iPhone 8"],["iPhone 6"],["iPhone 6s"],["iPhone 6 Plus"],["iPhone 6s Plus"]:
                let a = CGSize(width: 667, height: 375)
                if(self.scene!.size.width > a.width || self.scene!.size.height > a.height){
                    self.scene?.size = a
                    if(self.h==true){ self.configure()}
                }else{ if(self.h==true){self.configure()}}
                break;
            case ["iPhone 7 Plus"],["iPhone 8 Plus"]:
                let a = CGSize(width: 736, height: 414)
                if(self.scene!.size.width > a.width || self.scene!.size.height > a.height){
                    self.scene?.size = a
                    if(self.h==true){ self.configure()}
                }else{ if(self.h==true){self.configure()}}
                break;
            case ["iPhone X"],["iPhone 11 Pro"],["iPhone XS"]:
                let a = CGSize(width: 812, height: 375)
                if(self.scene!.size.width > a.width || self.scene!.size.height > a.height){
                    self.scene?.size = a
                    if(self.h==true){ self.configure()}
                }else{ if(self.h==true){self.configure()}}
                break;
            case ["iPhone 11 Pro Max"],["iPhone 11"]:
                let a = CGSize(width: 896, height: 414)
                if(self.scene!.size.width > a.width || self.scene!.size.height > a.height){
                    self.scene?.size = a
                    if(self.h==true){ self.configure()}
                }else{ if(self.h==true){self.configure()}}
                break;
            default:
                break;
            }
            
            if self.appDelegate.MPC.session.connectedPeers.count < 1 {
                self.scene?.removeAllChildren()
                self.label.text = "Connection lost"
                self.label.isHidden = false
                var a = SKLabelNode(text: "")
                a.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 50)
                a.fontSize = 30
                a.zPosition = 2
                a.color = UIColor.white
                var n = 5
                let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    n-=1
                    if(n==3){self.scene?.addChild(self.label)
                        self.scene?.addChild(a)}
                a.text = "You'll be redirected to the main menu in \(n)"

                    if self.appDelegate.MPC.session.connectedPeers.count == 1 {
                        a.removeFromParent()
                        timer.invalidate()
                    }
                      if n == 0 && self.appDelegate.MPC.session.connectedPeers.count < 1 {
                        self.appDelegate.MPC.serviceAdvertiser.stopAdvertisingPeer()
                        self.appDelegate.MPC.session.disconnect()
                           self.gameSceneDelegate?.didTapMainMenuButton(in: self)
                          timer.invalidate()
                      }
                  }

                timer.fire()
            }else{
                self.appDelegate.MPC.serviceAdvertiser.stopAdvertisingPeer()
            }
            
        }
    }
    
    func sendTextService(didReceive text: String) {
        
        
        OperationQueue.main.addOperation {
            if (text == "del"){
                self.player.removeFromParent()
                self.o = false
                self.u = true
                
            }
            let stringg = text.components(separatedBy: " ")
            if (stringg.count>1) {
                let a = stringg[0]
                let b = stringg[1]
                let c = stringg[2]
                
                if(a=="shot"){
                    guard let n = NumberFormatter().number(from: b) else { return }
                    guard let m = NumberFormatter().number(from: c) else { return }
                    if(self.o==true){
                        let missile = Missile.enemyMissile()
                        missile.position.x = self.player.position.x
                        missile.position.y = self.player.position.y - 35
                        if(self.w==2){ missile.texture = SKTexture(imageNamed:ImageName.Missile.rawValue)}else{
                           missile.texture = SKTexture(imageNamed:ImageName.Missile2.rawValue)
                        }
                     
                        missile.zPosition = self.zPosition - 1
                        
                        self.scene!.addChild(missile)
                        
                        // Make it move
                        let velocity: CGFloat = 1600.0
                        let moveDuration = self.scene!.size.height / velocity
                        let missileEndPosition = CGPoint(x: self.player.position.x, y: self.frame.minY)
                        
                        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
                        let removeAction = SKAction.removeFromParent()
                        missile.run(SKAction.sequence([moveAction, removeAction]))
                        
                        self.scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
                    }else {
                        let missile = Missile.enemyMissile()
                        
                        if(self.w==2){ missile.texture = SKTexture(imageNamed:ImageName.Missile.rawValue)}else{
                        missile.texture = SKTexture(imageNamed:ImageName.Missile2.rawValue)}
                        missile.position = CGPoint(x: self.frame.width - CGFloat(truncating: n), y: self.frame.maxY + CGFloat(truncating: m))
                        missile.zPosition = self.zPosition - 1
                        
                        if(self.q==false)
                        {self.scene!.addChild(missile)}
                        
                        let velocity: CGFloat = 1600.0
                        let moveDuration = self.scene!.size.height  / velocity
                        let missileEndPosition = CGPoint(x: self.frame.width - CGFloat(truncating: n), y: self.frame.minY)
                        
                        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
                        let removeAction = SKAction.removeFromParent()
                        missile.run(SKAction.sequence([moveAction, removeAction]))
                        
                    }
                    
                }
                else{
                    guard let d = NumberFormatter().number(from: a) else { return }
                    guard let e = NumberFormatter().number(from: b) else { return }
                    guard let f = NumberFormatter().number(from: c) else { return }
                    
                    if(self.u==true){
                        self.player.position.y = self.frame.maxY
                        self.player.position.x = self.frame.width - CGFloat(truncating: f)
                        
                        self.scene!.addChild(self.player)
                        self.u = false
                        self.o = true
                        
                    }
                    self.player.position.x -= CGFloat(truncating: d)
                    self.player.position.y -= CGFloat(truncating: e)
                    
                    
                } }
            if(text == "ok"){
                
                var a = 0
                let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    
                    a+=1
                    
                    
                    if a == 3 {
                        self.appDelegate.MPC.session.disconnect()
                        self.gameSceneDelegate?.playerDidLose(withScore: self.playerSpaceship.lifePoints,
                                                              in: self)
                        timer.invalidate()
                        
                    }
                }
                timer.fire()
                
            }
            if(text == "shoot"){
                self.handleCollision(between: Missile.enemyMissile(), and: self.playerSpaceship)
                

            }
            if(text == "up"){
                self.k=false
                self.destroySpaceship(self.player)
            }
            
            
            
        }
    }
    
}
