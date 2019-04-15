import Foundation
import UIKit
import SceneKit
import Ease

final class GameViewController: UIViewController {
    
    private var initialLocation: CGPoint = .zero
    private var disposal = EaseDisposal()
    private var ease: Ease<CGPoint> = Ease(.zero, minimumStep: 0.001)
    
    private lazy var cameraNode: SCNNode = {
        let node = SCNNode()
        node.camera = SCNCamera()
        node.camera?.usesOrthographicProjection = true
        
        node.camera?.bloomIntensity = 15
        node.camera?.bloomBlurRadius = 4
        node.camera?.bloomThreshold = 1.1
        
        node.camera?.wantsHDR = true
        node.camera?.wantsExposureAdaptation = false
        
        node.position = SCNVector3(x: 0, y: 0, z: 1.7)
        
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
        
        let materials = [
            SCNMaterial.plastic(.easeYellow),
            SCNMaterial.plastic(.easePurple),
            SCNMaterial.metal(.white)
        ]
        
        let pos = [
            SCNVector3(x: -1.01844, y: -0.00032, z: 0),
            SCNVector3(x: -0.291033, y: -0.038534, z: 0),
            SCNVector3(x: 0.359619, y: -0.005253, z: 0),
            SCNVector3(x: 0.971218, y: -0.00032, z: 0),
        ]
        
        for (i, childNode) in scene.rootNode.childNodes.enumerated() {
            childNode.geometry?.materials = materials
            childNode.position = pos[i]
            
            let tension = 1000 - (CGFloat(i) * 200)
            let damping = 75 + (CGFloat(i) * 25)
            let mass = 5 + (CGFloat(i) * 5)
            
            ease.addSpring(tension: tension, damping: damping, mass: mass, closure: { point, _ in
                childNode.runAction(SCNAction.rotateTo(x: point.y / 35, y: point.x / 250, z: 0, duration: 0))
            }).add(to: &disposal)
        }
        
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        scnView.backgroundColor = .easeYellow
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
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
