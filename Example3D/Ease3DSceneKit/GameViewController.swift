import Foundation
import UIKit
import SceneKit
import Ease

final class GameViewController: UIViewController {
    
    private var initialLocation: CGPoint = .zero
    private var disposal = EaseDisposal()
    private var ease: Ease<CGPoint> = Ease(.zero, minimumStep: 0.001)
    
    private lazy var cameraNode: SCNNode = {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.wantsHDR = true
        camera.wantsExposureAdaptation = false
        camera.bloomIntensity = 10
        camera.bloomBlurRadius = 60
        camera.bloomThreshold = 1
        if #available(iOS 13.0, *) {
            camera.bloomIterationCount = 10
            camera.bloomIterationSpread = 0.7
        }
        
        let node = SCNNode()
        node.position = SCNVector3(x: 0, y: 0, z: 1.8)
        node.camera = camera
        
        return node
    }()
    
    private lazy var scene: SCNScene = {
        let scene = SCNScene(named: "art.scnassets/EaseScene.scn")!
        scene.lightingEnvironment.contents = UIImage(named: "studio-lighting")
        scene.lightingEnvironment.intensity = 1.1
        
        return scene
    }()
    
    private var scnView: SCNView {
        guard let scnView = view as? SCNView else {
            fatalError("View is not a SCNView.")
        }
        
        return scnView
    }
    
    override func viewDidLoad() {   
        super.viewDidLoad()
        
        for (i, childNode) in scene.rootNode.childNodes.enumerated() {
            childNode.geometry?.materials = [
                .constant(.systemBlue),
                .plastic(.systemBlue),
                .constant(.white),
            ]
            
            let tension = 1000 - (CGFloat(i) * 200)
            let damping = 75 + (CGFloat(i) * 25)
            let mass = 5 + (CGFloat(i) * 5)
            
            ease.addSpring(tension: tension, damping: damping, mass: mass, closure: { point, _ in
                childNode.runAction(SCNAction.rotateTo(x: point.y / 35, y: point.x / 250, z: 0, duration: 0))
            }).add(to: &disposal)
        }
        
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        scnView.backgroundColor = .systemBlue
        scnView.gestureRecognizers = [UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))]
        scnView.antialiasingMode = .multisampling4X
        scnView.isJitteringEnabled = true
    }
    
    @objc func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
        case .possible, .began:
            initialLocation = location
        case .changed:
            var targetValue = gestureRecognizer.location(in: gestureRecognizer.view)
            targetValue.x -= initialLocation.x
            targetValue.y -= initialLocation.y
            ease.targetValue = targetValue
        case .ended, .cancelled, .failed:
            ease.targetValue = .zero
        @unknown default:
            fatalError()
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
}
