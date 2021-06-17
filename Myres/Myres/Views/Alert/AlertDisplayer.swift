//
//  AlertDisplayer.swift
//  Myres
//
//  Created by Luis Genesius on 05/05/21.
//

import UIKit

public class AlertDisplayer {
    
    public static let instance = AlertDisplayer()
    
    public var alertTextField: UITextField?
    
    public func showMessageAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))

        vc.present(alert, animated: true, completion: nil)
    }
    
    public func showCancelAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { action in
            
            NotificationCenter.default.post(name: Notification.Name("canceledAction\(vc)"), object: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))

        vc.present(alert, animated: true, completion: nil)
    }
    
    public func showOneTextFieldAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            
            self.alertTextField = alert.textFields![0]
            
            NotificationCenter.default.post(name: Notification.Name("oneFieldAlertAction\(vc)"), object: nil)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    public func showNewPhotoActionSheet(vc: UIViewController, title: String, message: String) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name("cameraAction"), object: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name("photoLibraryAction"), object: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    public func showEditPhoto(vc: UIViewController, title: String, message: String) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name("updateAction"), object: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name("shareAction"), object: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    } 
    
}
