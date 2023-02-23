
import SpriteKit

class ScoresNode: SKLabelNode {
    
    var value: Int = 0 {
        didSet {
            update()
        }
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        fontSize = 18.0
        fontColor = UIColor(white: 1, alpha: 0.7)
        fontName = FontName.Wawati.rawValue
        horizontalAlignmentMode = .left;
        
        update()
    }
    
    // MARK: - Configuration
    
    func update() {
        text = "Score: \(value)"
    }
    
}
