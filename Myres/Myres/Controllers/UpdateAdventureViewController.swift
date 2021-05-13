//
//  UpdateAdventureViewController.swift
//  Myres
//
//  Created by Luis Genesius on 05/05/21.
//

import UIKit

class UpdateAdventureViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var storyTextField: UITextField!
    @IBOutlet weak var selectedAlbumButton: UIButton!
    
    // MARK: - Attributes
    public var selectedAdventure: Adventure?
    
    private var transparentView: UIView!
    
    private let albumTableView = UITableView()
    
    private var albums = [Album]()
    private var getSelectedAlbum: Album?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setRightBarButton()
        setTextFieldUI()
        setButtonUI()
        setInitialText()
        
        albumTableView.delegate = self
        albumTableView.dataSource = self
        albumTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "albumUpdateCell")
        loadAlbums()
        
    }
    
    private func setRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
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
        selectedAlbumButton.layer.borderWidth = 1
        selectedAlbumButton.layer.borderColor = UIColor.label.cgColor
        selectedAlbumButton.layer.cornerRadius = 10
    }
    
    private func setInitialText() {
        titleTextField.text = selectedAdventure?.title
        locationTextField.text = selectedAdventure?.location
        storyTextField.text = selectedAdventure?.story
        
        if let album = selectedAdventure?.parentAlbum {
            selectedAlbumButton.setTitle(album.title, for: .normal)
            getSelectedAlbum = album
        }
        
    }
    
    private func loadAlbums() {
        if let tempAlbums = CoreDataService.instance.fetchAllAlbums() {
            albums = tempAlbums
        }
        
        DispatchQueue.main.async {
            self.albumTableView.reloadData()
        }
    }
    
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
        albumTableView.frame = CGRect(x: selectedAlbumButton.frame.origin.x, y: selectedAlbumButton.frame.origin.y + selectedAlbumButton.frame.height, width: selectedAlbumButton.frame.width, height: 0)
        view.addSubview(albumTableView)
        albumTableView.layer.cornerRadius = 5
        
        albumTableView.reloadData()
    }
    
    @objc func removeTransparentView() {
        setAnimation(transparentViewAlpha: 0, additionalY: 0, height: 0)
    }
    
    // MARK: - Set Tap Gesture
    
    private func setTransViewTapGesture() {
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
    }
    
    // MARK: - Set Animation
    
    private func setAnimation(transparentViewAlpha: CGFloat, additionalY: CGFloat, height: CGFloat) {
        let frames = selectedAlbumButton.frame
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = transparentViewAlpha
            self.albumTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + additionalY, width: frames.width, height: height)
        }, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Alert
    
    private func showValidationAlert() {
        let alert = UIAlertController(title: "No Empty Text", message: "You must enter text in the field", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Button Action
    
    @objc func saveTapped() {
        if let titleText = self.titleTextField.text, !titleText.isEmpty, let locationText = self.locationTextField.text, !locationText.isEmpty, let storyText = self.storyTextField.text, !storyText.isEmpty {
            
            CoreDataService.instance.updateAdventure(adventure: selectedAdventure!, title: titleText, location: locationText, story: storyText, album: getSelectedAlbum)
            
            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.sizeToFit()
            
            navigationController?.popToRootViewController(animated: true)
            
        } else {
            showValidationAlert()
        }
    }

    @IBAction func selectAlbumAction(_ sender: Any) {
        addAlbumSelectedUI()
    }
}

// MARK: - Text Field Delegate

extension UpdateAdventureViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UpdateAdventureViewController: UITableViewDelegate {
    
}

extension UpdateAdventureViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumTableView.dequeueReusableCell(withIdentifier: "albumUpdateCell", for: indexPath)
        
        cell.textLabel?.text = albums[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlbumButton.setTitle(albums[indexPath.row].title, for: .normal)
        getSelectedAlbum = albums[indexPath.row]
        removeTransparentView()
    }
}
