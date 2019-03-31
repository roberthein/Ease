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
        material.roughness.intensity = 0.1
        
        material.emission.contents = color
        material.emission.intensity = 0.4
        
        return material
    }
    
    class func metal(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        
        material.metalness.contents = UIColor.white
        material.metalness.intensity = 0.8
        
        material.roughness.contents = UIImage(named: "gold-scratch-roughness")
        material.roughness.intensity = 0.2
        
        material.normal.contents = UIImage(named: "gold-scratch-normal")
        material.normal.intensity = 0.2
        
        material.emission.contents = color
        material.emission.intensity = 0.2
        
        return material
    }
}
    
extension UIColor {
    
    class func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    class var easeYellow: UIColor {
        return rgb(240, 222, 201)
    }
    
    class var easeGreen: UIColor {
        return rgb(143, 204, 184)
    }
    
    class var easeRed: UIColor {
        return rgb(242, 131, 97)
    }
    
    class var easePurple: UIColor {
        return rgb(88, 82, 144)
    }
}
