import Foundation
import SceneKit
import UIKit

extension SCNMaterial {
    
    class func plastic(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        
        material.metalness.contents = UIColor.white
        material.metalness.intensity = 0
        
        material.roughness.contents = UIColor.white
        material.roughness.intensity = 1
        
        material.selfIllumination.contents = UIColor.white
        material.selfIllumination.intensity = 1
        
        if #available(iOS 13.0, *) {
            material.clearCoat.contents = UIColor.white
        }
        
        return material
    }
    
    class func constant(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = color
        
        return material
    }
}
