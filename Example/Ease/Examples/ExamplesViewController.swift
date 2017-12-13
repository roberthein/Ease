import UIKit
import Ease
import SceneKit

protocol ExampleViewController {
    func createCircles() -> [Circle]
}

extension ExampleViewController where Self: UIViewController {
    
    func createCircles() -> [Circle] {
        return [
            Circle(color: .tintColor1, size: 125),
            Circle(color: .tintColor1, size: 100),
            Circle(color: .tintColor1, size: 75),
            Circle(color: .tintColor1, size: 50),
            Circle(color: .tintColor1, size: 25)
        ]
    }
}

class ExamplesViewController: UITableViewController {
    
    let cellReuseIdentifier = "CellReuseIdentifier"
    let exampleTitles = ["Touch", "Scroll", "Gyro"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleTitles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = exampleTitles[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController: UIViewController
        
        switch indexPath.row {
        case 0: viewController = GesturesViewController()
        case 1: viewController = ScrollingViewController()
        case 2: viewController = GyroscopeViewController()
        default: fatalError()
        }
        
        viewController.title = exampleTitles[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}
