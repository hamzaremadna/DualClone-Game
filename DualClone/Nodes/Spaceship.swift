

import SpriteKit

class Spaceship: SKSpriteNode, LifePointsProtocol,Ammoprotocol {
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    // MARK: - LifePointsProtocol
    
    var didRunOutOfLifePointsEventHandler: DidRunOutOfLifePointsEventHandler? = nil
    
    var lifePoints: Int = 0 {
        didSet {
            if lifePoints <= 0 {
                didRunOutOfLifePointsEventHandler?(self)
            }
        }
    }
    
    var didRunOutOfAmmoEventHandler: DidRunOutOfAmmoEventHandler? = nil
       
       var ammonumber: Int = 0 {
           didSet {
               if ammonumber <= 0 {
                   didRunOutOfAmmoEventHandler?(self)
               }
           }
       }
    
}
