//
//  AlbumsViewController.swift
//  Myres
//
//  Created by Luis Genesius on 28/04/21.
//

import UIKit

class AlbumsViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    // MARK: - Attributes
    
    private var albums = [Album]()
    private var selectedIndexPath: IndexPath?
    
    private var condition: Mode.Condition = .unselect {
        didSet {
            switchCondition()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        loadAlbums()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: Notification.Name("updatePhotoAlbum"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveAlbum), name: Notification.Name("oneFieldAlertAction\(self)"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Set UI
    
    private func loadAlbums() {
        if let albums = CoreDataService.instance.fetchAllAlbums() {
            self.albums = albums
        }
        
        DispatchQueue.main.async {
            self.albumCollectionView.reloadData()
        }
    }
    
    @objc func reloadCollectionView() {
        DispatchQueue.main.async {
            self.albumCollectionView.reloadData()
        }
    }
    
    @objc func saveAlbum() {
        guard let textField = AlertDisplayer.instance.alertTextField else { return }
        
        CoreDataService.instance.saveAlbum(title: textField.text!)
        
        AlertDisplayer.instance.alertTextField = nil
        
        NotificationCenter.default.post(name: Notification.Name("albumAdded"), object: nil)
        self.loadAlbums()
    }
    
    private func switchCondition() {
        switch condition {
        case .unselect:
            unselectCondition()
        case .selected:
            selectedCondition()
        }
    }

    private func unselectCondition() {
        rightBarButton.title = "Select"
        leftBarButton.image = UIImage(systemName: "plus")
        leftBarButton.tintColor = nil
        leftBarButton.isEnabled = true
        self.tabBarController!.tabBar.items?.forEach { $0.isEnabled = true }
    }
    
    private func selectedCondition() {
        rightBarButton.title = "Cancel"
        leftBarButton.image = UIImage(systemName: "trash")
        leftBarButton.tintColor = .clear
        leftBarButton.isEnabled = false
        self.tabBarController!.tabBar.items?.forEach { $0.isEnabled = false }
    }
    
    private func setCanceledUI() {
        if selectedIndexPath != nil {
            albumCollectionView.deselectItem(at: selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
    }
    
    private func showRemoveIcon() {
        if selectedIndexPath != nil {
            leftBarButton.tintColor = nil
            leftBarButton.isEnabled = true
        } else {
            leftBarButton.tintColor = .clear
            leftBarButton.isEnabled = false
        }
    }
    
    // MARK: - Button Action
    
    @IBAction func selectTapButton(_ sender: Any) {
        condition = (condition == .unselect) ? .selected : .unselect; setCanceledUI()
    }
    
    @IBAction func leftTapButton(_ sender: Any) {
        (condition == .unselect) ? plusTapped() : removeTapped()
    }
    
    private func plusTapped() {
        AlertDisplayer.instance.showOneTextFieldAlert(vc: self, title: "New Album", message: "Enter albu's title.")
    }
    
    private func removeTapped() {
        if let adventures = CoreDataService.instance.fetchAdventuresBasedOnAlbum(album: albums[selectedIndexPath!.row]) {
            
            for adventure in adventures {
                adventure.parentAlbum = nil
            }
        }
        
        CoreDataService.instance.deleteAlbum(album: albums[selectedIndexPath!.row])
        selectedIndexPath = nil
        
        NotificationCenter.default.post(name: Notification.Name("albumAdded"), object: nil)
        
        showRemoveIcon()
        loadAlbums()
    }
    
    // MARK: - Navigation
    
    private func navigateToAlbumsDetail(indexPath: IndexPath) {
        albumCollectionView.deselectItem(at: indexPath, animated: true)
        
        let detailAlbumVC = storyboard?.instantiateViewController(identifier: "detailAlbum") as! DetailAlbumViewController
        
        detailAlbumVC.title = albums[indexPath.row].title
        detailAlbumVC.album = albums[indexPath.row]
        
        self.navigationController?.pushViewController(detailAlbumVC, animated: true)
    }
    
}

// MARK: - Collection View Delegate

extension AlbumsViewController: UICollectionViewDelegate {
    
}

// MARK: - Collection View Data Source

extension AlbumsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        
        cell.layer.cornerRadius = 10
        
        if let firstImage = albums[indexPath.row].fetchFirstImageFromChild() {
            
            cell.albumImageView.image = FileManagerService.instance.getImageFromStorage(imageName: firstImage)
        } else {
            cell.albumImageView.image = UIImage(named: "question-mark")
        }
        cell.albumLabel.text = albums[indexPath.row].title
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.label.cgColor
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch condition {
        case .unselect:
            navigateToAlbumsDetail(indexPath: indexPath)
            break
        case .selected:
            selectedIndexPath = indexPath
            showRemoveIcon()
        }
    }
}
