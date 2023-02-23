
import SpriteKit

protocol MainMenuSceneDelegate: class {
    
    func mainMenuSceneDidTaphostButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapjoinButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene: MainMenuScene)
}

class MainMenuScene: MenuScene {
    
    private var infoButton: Button?
    private var hostButton: Button?
    private var joinButton: Button?
    private var buttons: [Button]?
    weak var mainMenuSceneDelegate: MainMenuSceneDelegate?

    
    // MARK: - Scene lifecycle
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        configureButtons()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
    }

    // MARK: - Configuration

    private func configureButtons() {
        // Info button.
        infoButton = Button(normalImageNamed: ImageName.MenuButtonInfoNormal.rawValue,
                            selectedImageNamed: ImageName.MenuButtonInfoNormal.rawValue)
        infoButton!.touchUpInsideEventHandler = infoButtonTouchUpInsideHandler()
        infoButton!.position = CGPoint(x: scene!.size.width - 40.0,
                                       y: scene!.size.height - 25.0)
        addChild(infoButton!)
        
        // Resume button.
        hostButton = Button(normalImageNamed: ImageName.MenuButtonResumeNormal.rawValue,
                              selectedImageNamed: ImageName.MenuButtonResumeNormal.rawValue)
        hostButton!.touchUpInsideEventHandler = hostButtonTouchUpInsideHandler()
        
        // Restart button.
        joinButton = Button(normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
                               selectedImageNamed: ImageName.MenuButtonRestartNormal.rawValue)
        joinButton!.touchUpInsideEventHandler = joinButtonTouchUpInsideHandler()
        
        buttons = [hostButton!, joinButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in buttons!.enumerated() {
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != buttons!.count - 1 ? horizontalPadding : 0.0
        }
        
        // Calculate origin of first button.
        var buttonOriginX = frame.width / 2.0 + totalButtonsWidth / 2.0
        
        // Place buttons in the scene.
        for (_, button) in buttons!.enumerated() {
            button.position = CGPoint(x: buttonOriginX - button.size.width/2,
                                      y: button.size.height * 1.1)
            addChild(button)
            
            buttonOriginX -= button.size.width + horizontalPadding
            
            let rotateAction = SKAction.rotate(byAngle: CGFloat(.pi/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversed()])
            button.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func hostButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.mainMenuSceneDelegate?.mainMenuSceneDidTaphostButton(strongSelf)
        }
    }
    
    private func joinButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.mainMenuSceneDelegate?.mainMenuSceneDidTapjoinButton(strongSelf)
        }
    }
    
    private func infoButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.mainMenuSceneDelegate?.mainMenuSceneDidTapInfoButton(strongSelf)
        }
    }
    
}
