import SpriteKit

class Ammo: SKSpriteNode {
    fileprivate var titleLabelNode: SKLabelNode?

    fileprivate var ammonumber: Int = 10 {
        didSet {
            update(animated: false)
        }
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(texture: SKTexture!) {
        super.init(texture: texture,
                   color: UIColor.brown,
                   size: texture.size())
        

        // Configure title
            titleLabelNode = SKLabelNode(fontNamed: FontName.Wawati.rawValue)
            titleLabelNode!.fontSize = 14.0
            titleLabelNode!.fontColor = UIColor(white: 1.0, alpha: 0.7)
            titleLabelNode!.horizontalAlignmentMode = .center
            titleLabelNode!.verticalAlignmentMode = .center
            
            update(animated: false)
            
            addChild(titleLabelNode!)
    }
    
    // MARK: - Configuration
    
    func setAmmonumber(_ points: Int, animated: Bool) {
        ammonumber = points
        
        update(animated: animated)
    }
    
    fileprivate func update(animated: Bool) {
        titleLabelNode!.text = "\(ammonumber)"

        let blendColor = Ammoballcolor()
        let blendFactor: CGFloat = 1.0
        
        if animated {
            let colorizeAction = SKAction.colorize(with: blendColor, colorBlendFactor: blendFactor, duration: 0.2)
            let scaleUpAction = SKAction.scale(by: 1.2, duration: 0.2)
            let scaleActionSequence = SKAction.sequence([scaleUpAction, scaleUpAction.reversed()])
            titleLabelNode!.color = blendColor
                       titleLabelNode!.colorBlendFactor = blendFactor
            
     
            
            run(SKAction.group([colorizeAction, scaleActionSequence]))
        } else {
            color = blendColor
            colorBlendFactor = blendFactor
            titleLabelNode!.color = blendColor
             titleLabelNode!.colorBlendFactor = blendFactor
     
        }
    }
    
    fileprivate func Ammoballcolor() -> UIColor {
        var fullBarColorR: CGFloat = 0.0, fullBarColorG: CGFloat = 0.0, fullBarColorB: CGFloat = 0.0, fullBarColorAlpha: CGFloat = 0.0
        var emptyBarColorR: CGFloat = 0.0, emptyBarColorG: CGFloat = 0.0, emptyBarColorB: CGFloat = 0.0, emptyBarColorAlpha: CGFloat = 0.0
        
        UIColor.green.getRed(&fullBarColorR, green: &fullBarColorG, blue: &fullBarColorB, alpha: &fullBarColorAlpha)
        UIColor.red.getRed(&emptyBarColorR, green: &emptyBarColorG, blue: &emptyBarColorB, alpha: &emptyBarColorAlpha)
        
        let resultColorR = emptyBarColorR + CGFloat(ammonumber)/10 * (fullBarColorR - emptyBarColorR)
        let resultColorG = emptyBarColorG + CGFloat(ammonumber)/10 * (fullBarColorG - emptyBarColorG)
        let resultColorB = emptyBarColorB + CGFloat(ammonumber)/10 * (fullBarColorB - emptyBarColorB)
        
        return UIColor(red: resultColorR, green: resultColorB, blue: resultColorG, alpha: 1.0)
    }
    
}
