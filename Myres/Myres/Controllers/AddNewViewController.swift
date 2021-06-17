//
//  AddNewViewController.swift
//  Myres
//
//  Created by Luis Genesius on 28/04/21.
//

import UIKit
import PhotosUI

class AddNewViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var storyTextField: UITextField!
    
    @IBOutlet weak var selectAlbumButton: UIButton!

    @IBOutlet weak var addPhotoButton: UIButton!
    
    // MARK: - Attributes
    
    private var transparentView: UIView!
    
    private let albumTableView = UITableView()
    
    private var albums = [Album]()
    private var getSelectedAlbum: Album?
    private var photoDate: Date?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        albumTableView.delegate = self
        albumTableView.dataSource = self
        albumTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "albumCell")
        loadAlbums()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectorLoadAlbums), name: Notification.Name("albumAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelAction), name: Notification.Name("canceledAction\(self)"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(takePhotoAction), name: Notification.Name("cameraAction"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(photoLibraryAction), name: Notification.Name("photoLibraryAction"), object: nil)
        
        setPhotoUI()
        setTextFieldUI()
        setButtonUI()
        setElementInvisible()
    }
    
    // MARK: - Set UI
    
    private func loadAlbums() {
        
        if let tempAlbums = CoreDataService.instance.fetchAllAlbums() {
            albums = tempAlbums
        }
        
        DispatchQueue.main.async {
            self.albumTableView.reloadData()
        }
    }
    
    private func setTextFieldUI() {
        titleTextField.delegate = self
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.label.cgColor
        titleTextField.layer.cornerRadius = 10
        
        locationTextField.delegate = self
        locationTextField.layer.borderWidth = 1
        locationTextField.layer.borderColor = UIColor.label.cgColor
        locationTextField.layer.cornerRadius = 10
        
        storyTextField.delegate = self
        storyTextField.layer.borderWidth = 1
        storyTextField.layer.borderColor = UIColor.label.cgColor
        storyTextField.layer.cornerRadius = 10
    }
    
    private func setButtonUI() {
        addPhotoButton.layer.cornerRadius = 10
        selectAlbumButton.layer.borderWidth = 1
        selectAlbumButton.layer.borderColor = UIColor.label.cgColor
        selectAlbumButton.layer.cornerRadius = 10
    }
    
    private func setPhotoUI() {
        photoImageView.isHidden = true
    }
    
    private func setElementVisible() {
        titleTextField.isHidden = false
        locationTextField.isHidden = false
        storyTextField.isHidden = false
        selectAlbumButton.isHidden = false
        photoImageView.isHidden = false
        
        saveBarButton.isEnabled = true
        saveBarButton.tintColor = nil
        
        cancelBarButton.isEnabled = true
        cancelBarButton.tintColor = .red
    }
    
    private func setElementInvisible() {
        titleTextField.isHidden = true
        locationTextField.isHidden = true
        storyTextField.isHidden = true
        selectAlbumButton.isHidden = true
        photoImageView.isHidden = true
        
        saveBarButton.isEnabled = false
        saveBarButton.tintColor = .clear
        
        cancelBarButton.isEnabled = false
        cancelBarButton.tintColor = .clear
    }
    
    private func discardElements() {
        infoLabel.isHidden = false
        setElementInvisible()
        photoImageView.image = nil
        photoDate = nil
        makeToNormal()
        
    }
    
    // MARK: - Set Select Album UI
    
    private func addAlbumSelectedUI() {
        setTransparentView()
        setAlbumTableView()
        setTransViewTapGesture()
        setAnimation(transparentViewAlpha: 0.5, additionalY: 5, height: CGFloat(3 * 40))
    }
    
    private func setTransparentView() {
        transparentView = UIVisualEffectView()
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        transparentView.backgroundColor = UIColor.label.withAlphaComponent(0.9)
    }
    
    private func setAlbumTableView() {
        albumTableView.frame = CGRect(x: selectAlbumButton.frame.origin.x, y: selectAlbumButton.frame.origin.y + selectAlbumButton.frame.height, width: selectAlbumButton.frame.width, height: 0)
        view.addSubview(albumTableView)
        albumTableView.layer.cornerRadius = 5
        
        albumTableView.reloadData()
    }
    
    @objc func removeTransparentView() {
        setAnimation(transparentViewAlpha: 0, additionalY: 0, height: 0)
    }
    
    private func makeToNormal() {
        selectAlbumButton.setTitle("Select Album        ", for: .normal)
        titleTextField.text = ""
        locationTextField.text = ""
        storyTextField.text = ""
    }
    
    // MARK: - Set Tap Gesture
    
    private func setTransViewTapGesture() {
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
    }
    
    // MARK: - Set Animation
    
    private func setAnimation(transparentViewAlpha: CGFloat, additionalY: CGFloat, height: CGFloat) {
        let frames = selectAlbumButton.frame
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = transparentViewAlpha
            self.albumTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + additionalY, width: frames.width, height: height)
        }, completion: nil)
    }
    
    // MARK: - Set Action Sheet
    
    private func setActionSheet() {
        AlertDisplayer.instance.showNewPhotoActionSheet(vc: self, title: "Choose Photo Source", message: "Do you want to add photo from photo library or take picture using new camera ?")
    }
    
    private func takePicture() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func addPhotoFromLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Save Method
    
    private func saveAdventure(title: String, location: String, story: String) {
        
        guard let dateNow = photoDate else { return }
        
        let imageName = UUID().uuidString
        FileManagerService.instance.saveImageToStorage(image: photoImageView.image!, imageName: imageName)

        var album: Album?
        
        if let selectedAlbum = getSelectedAlbum {
            album = selectedAlbum
        }
        
        let bool = CoreDataService.instance.saveAdventure(title: title, location: location, story: story, date: dateNow, photo: imageName, album: album)
        
        NotificationCenter.default.post(name: Notification.Name("adventureAdded"), object: nil)
        
        (bool == true) ? displaySuccessMessage() : showFailedSaveMessage()
    }
    
    private func displaySuccessMessage() {
        print("Success Save")
        
        AlertDisplayer.instance.showMessageAlert(vc: self, title: "Success Save", message: "You successfully added new adventure.")
        
        discardElements()
        
        titleTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        storyTextField.resignFirstResponder()
    }
    
    private func showFailedSaveMessage() {
        print("Failed Save")
        
        AlertDisplayer.instance.showMessageAlert(vc: self, title: "Failed Save", message: "You have failed to add new adventure.")
    }
    
    // MARK: - Selector Actions
    
    @objc func selectorLoadAlbums() {
        loadAlbums()
    }
    
    @objc func cancelAction() {
        self.discardElements()
    }
    
    @objc func takePhotoAction() {
        self.takePicture()
    }
    
    @objc func photoLibraryAction() {
        self.addPhotoFromLibrary()
    }

    // MARK: - Button Actions
    
    @IBAction func addPhotoAction(_ sender: Any) {
        setActionSheet()
    }
    
    @IBAction func selectAlbumAction(_ sender: Any) {
        addAlbumSelectedUI()
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if let titleText = self.titleTextField.text, !titleText.isEmpty, let locationText = self.locationTextField.text, !locationText.isEmpty, let storyText = self.storyTextField.text, !storyText.isEmpty {
            
            saveAdventure(title: titleText, location: locationText, story: storyText)
            
        } else {
            AlertDisplayer.instance.showMessageAlert(vc: self, title: "No Empty Text", message: "You must enter text in the field.")
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        AlertDisplayer.instance.showCancelAlert(vc: self, title: "Confirmation", message: "Are you sure you want to discard ?")
    }

}

// MARK: - Text Field Delegate

extension AddNewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Image Picker Delegate

extension AddNewViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
    
        photoDate = Date()
        infoLabel.isHidden = true
        setElementVisible()
        photoImageView?.image = image
    }
}

// MARK: - Navigation Delegate

extension AddNewViewController: UINavigationControllerDelegate {
    
}

// MARK: - Table View Delegate

extension AddNewViewController: UITableViewDelegate {
    
}

// MARK: - Table View Data Source

extension AddNewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumTableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath)
        
        cell.textLabel?.text = albums[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAlbumButton.setTitle(albums[indexPath.row].title, for: .normal)
        getSelectedAlbum = albums[indexPath.row]
        removeTransparentView()
    }
}
