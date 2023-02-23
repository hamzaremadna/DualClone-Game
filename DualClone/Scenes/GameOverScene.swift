
import SpriteKit

protocol GameOverSceneDelegate: class {
    func gameOverSceneDidTapmainButton(_ gameOverScene: GameOverScene)

}

class GameOverScene: MenuScene {
    
    private var mainButton: Button?
    private var buttons: [Button]?
    weak var gameOverSceneDelegate: GameOverSceneDelegate?
    private var label = SKLabelNode(fontNamed: FontName.Wawati.rawValue)

    
    // MARK: - Scene lifecycle
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        let defaults = UserDefaults.standard
        let score = defaults.integer(forKey: "score")
        label.position = CGPoint(x: frame.width/2, y: frame.height/2)
               label.fontSize = 50
        if(score==0){
            label.text = "You Lose"}else{
            label.text = "You Win"
        }
               label.zPosition = 2
               label.color = UIColor.white
               addChild(label)
        configureButtons()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        }
    
    // MARK: - Configuration
    
    private func configureButtons() {
        // Restart button
        mainButton = Button(
            normalImageNamed: ImageName.MenuButtonMainNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonMainNormal.rawValue)
        
        mainButton!.touchUpInsideEventHandler = mainButtonTouchUpInsideHandler()
        
        buttons = [mainButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in (buttons!).enumerated() {
            
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != buttons!.count - 1 ? horizontalPadding : 0.0
        }
        
        var buttonOriginX = frame.width / 2.0 + totalButtonsWidth / 2.0
        
        for (_, button) in (buttons!).enumerated() {
            button.position = CGPoint(
                x: buttonOriginX - button.size.width/2,
                y: button.size.height * 1.1)
            
            addChild(button)
            
            buttonOriginX -= button.size.width + horizontalPadding
            
            let rotateAction = SKAction.rotate(byAngle: CGFloat(.pi/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversed()])
            
            button.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func mainButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        let handler = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.gameOverSceneDelegate?.gameOverSceneDidTapmainButton(strongSelf)
        }
        
        return handler
    }
    
}
