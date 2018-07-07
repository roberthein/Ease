import Foundation
import UIKit

class Circle: UIView {
    
    required init(color: UIColor, size: CGFloat) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        
        backgroundColor = color.withAlphaComponent(0.3)
        layer.cornerRadius = size / 2
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
