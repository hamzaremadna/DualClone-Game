

import UIKit
import SpriteKit
import MultipeerConnectivity


class GameViewController: UIViewController,MCBrowserViewControllerDelegate {
    
    
    var appDelegate:AppDelegate!

    
    @IBOutlet var swipe: UISwipeGestureRecognizer!
    
    @IBOutlet weak var imageview: UIImageView!
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.MPC.browser.dismiss(animated: true, completion: nil)

    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.MPC.serviceAdvertiser.stopAdvertisingPeer()
        appDelegate.MPC.browser.dismiss(animated: true, completion: nil)
        showMainMenuScene(animated: true)

    }
    
    
    private struct Constants {
        static let sceneTransistionDuration: Double = 0.2
    }
    
    private var gameScene: GameScene?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview.image = UIImage(named: ImageName.PlayerSpaceship.rawValue)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
         let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
             
         leftSwipe.direction = .left
         rightSwipe.direction = .right

         view.addGestureRecognizer(leftSwipe)
         view.addGestureRecognizer(rightSwipe)
        imageview.isHidden = false
        let defaults = UserDefaults.standard
                       defaults.set(1, forKey: "spaceship")

        configureView()
        showMainMenuScene(animated: false)
     // MusicManager.shared.playBackgroundMusic()
    }
    
    // MARK: - Appearance

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
            
        if (sender.direction == .left) {
            imageview.image = UIImage(named: ImageName.EnemySpaceship.rawValue)

            let defaults = UserDefaults.standard
                 defaults.set(2, forKey: "spaceship")
        }
            
        if (sender.direction == .right) {
            imageview.image = UIImage(named: ImageName.PlayerSpaceship.rawValue)
            let defaults = UserDefaults.standard
                            defaults.set(1, forKey: "spaceship")

        }
    }
    override var shouldAutorotate : Bool {
        return true
    }

    // Make sure only the landscape mode is supported
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var prefersStatusBarHidden : Bool {
        // Hide the status bar
        return true
    }
    
}

// MARK: - Scene handling

extension GameViewController {
    
    private func startNewGame(animated: Bool = false) {
        
        gameScene = GameScene(size: view.frame.size)
         gameScene!.scaleMode = .aspectFill
         gameScene!.gameSceneDelegate = self
         
         show(gameScene!, animated: animated)
    }
    
    private func showMainMenuScene(animated: Bool) {
        // Create main menu scene
        imageview.isHidden = false

        let scene = MainMenuScene(size: view.frame.size)
        scene.mainMenuSceneDelegate = self
        
        // Pause the game
        
        // Show it
        show(scene, animated: animated)
    }
    
    private func showGameOverScene(animated: Bool) {
        // Create game over scene
        let scene = GameOverScene(size: view.frame.size)
        scene.gameOverSceneDelegate = self
        
        // Pause the game
        
        // Show it
        show(scene, animated: animated)
    }

    private func show(_ scene: SKScene, scaleMode: SKSceneScaleMode = .aspectFill, animated: Bool = true) {
        guard let skView = view as? SKView else {
            preconditionFailure()
        }

        scene.scaleMode = .aspectFill

        if animated {
            skView.presentScene(scene, transition: SKTransition.crossFade(withDuration: Constants.sceneTransistionDuration))
        } else {
            skView.presentScene(scene)
        }
    }

}

// MARK: - GameSceneDelegate

extension GameViewController : GameSceneDelegate {

    func didTapMainMenuButton(in gameScene: GameScene) {
        // Show initial, main menu scene
        showMainMenuScene(animated: true)
    }
    
    func playerDidLose(withScore score: Int, in gameScene:GameScene) {
        // Player lost, show game over scene
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: "score")
        showGameOverScene(animated: true)
    }
    
}

// MARK: - MainMenuSceneDelegate

extension GameViewController : MainMenuSceneDelegate {
    
    func mainMenuSceneDidTaphostButton(_ mainMenuScene: MainMenuScene) {
        imageview.isHidden = true
            self.startNewGame(animated: true)
        
    }
    
    func mainMenuSceneDidTapjoinButton(_ mainMenuScene: MainMenuScene) {
        imageview.isHidden = true
        self.startNewGame(animated: true)
        if appDelegate.MPC.session != nil{
                   appDelegate.MPC.setupBrowser()
                 appDelegate.MPC.browser.delegate = self
            self.present(appDelegate.MPC.browser, animated: true, completion: nil)
                   
               }
    }
    
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene:MainMenuScene) {
        // Create a simple alert with copyright information
        let alertController = UIAlertController(title: "About",
                                                message: "Hamza Remadna / Multipeer Connectivity DualClone",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        // Show it
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - GameOverSceneDelegate

extension GameViewController : GameOverSceneDelegate {
    
    func gameOverSceneDidTapmainButton(_ gameOverScene: GameOverScene) {
        // TODO: Remove game over scene here
        
        showMainMenuScene(animated: false)
    }
    
}

// MARK: - Configuration

extension GameViewController {
    
    private func configureView() {
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        
        // Enable debugging
        #if DEBUG
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
        #endif
    }
    
}
