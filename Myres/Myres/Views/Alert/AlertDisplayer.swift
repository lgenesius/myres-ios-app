import UIKit

public class AlertDisplayer {
    
    public static let instance = AlertDisplayer()
    
    public var alertTextField: UITextField?
    
    public func showMessageAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))

        vc.present(alert, animated: true, completion: nil)
    }
    
    public func showConfirmationAlert(vc: UIViewController, title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Sure", style: UIAlertAction.Style.destructive, handler: { action in
            completion()
        }))

        vc.present(alert, animated: true, completion: nil)
    }
    
    public func showOneTextFieldAlert(vc: UIViewController, title: String, message: String, completion: @escaping (UITextField?) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            completion(alert.textFields?.first)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    public func showNewPhotoActionSheet(vc: UIViewController, title: String, message: String, completion: @escaping (UIAlertAction) -> Void) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            actionSheet.dismiss(animated: true) {
                completion(action)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            completion(action)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    public func showEditPhoto(vc: UIViewController, title: String, message: String, completion: @escaping (UIAlertAction) -> Void) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action:UIAlertAction) in
            actionSheet.dismiss(animated: true) {
                completion(action)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action:UIAlertAction) in
            actionSheet.dismiss(animated: true) {
                completion(action)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    } 
    
}
