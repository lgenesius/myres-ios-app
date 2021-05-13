//
//  DetailAlbumViewController.swift
//  Myres
//
//  Created by Luis Genesius on 03/05/21.
//

import UIKit

class DetailAlbumViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var selectBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    // MARK: - Attributes
    
    public var album: Album?
    private var adventures = [Adventure]()
    private var images = [UIImage]()
    
    private var condition: Mode.Condition = .unselect {
        didSet {
            switchCondition()
        }
    }
    
    private var dictionarySelectedIndexPath: [IndexPath:Bool] = [:]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        loadAdventures()
        NotificationCenter.default.addObserver(self, selector: #selector(selectorLoadAdventures), name: Notification.Name("adventureAdded"), object: nil)
        
        setInitialUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.sizeToFit()
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Set UI
    
    private func setInitialUI() {
        deleteBarButton.tintColor = .clear
        deleteBarButton.isEnabled = false
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
        selectBarButton.title = "Select"
        deleteBarButton.tintColor = .clear
        deleteBarButton.isEnabled = false
        detailCollectionView.allowsMultipleSelection = false
        self.tabBarController!.tabBar.items?.forEach { $0.isEnabled = true }
    }
    
    private func selectedCondition() {
        selectBarButton.title = "Cancel"
        detailCollectionView.allowsMultipleSelection = true
        self.tabBarController!.tabBar.items?.forEach { $0.isEnabled = false }
    }
    
    @objc func selectorLoadAdventures() {
        loadAdventures()
    }
    
    private func loadAdventures() {
        images.removeAll()
        
        if let album = album, let tempAdventures = CoreDataService.instance.fetchAdventuresBasedOnAlbum(album: album) {
            adventures = tempAdventures
        }
        
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
        }
    }
    
    private func setCanceledUI() {
        dictionarySelectedIndexPath.removeAll()
        
        guard let selectedItems = detailCollectionView.indexPathsForSelectedItems else { return }
        
        for indexPath in selectedItems {
            detailCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    private func checkSelectedCell() {
        var check = false
        for value in dictionarySelectedIndexPath.values {
            if value {
                check = true
                break
            }
        }
        
        if check == false {
            deleteBarButton.tintColor = .clear
            deleteBarButton.isEnabled = false
        }
    }
    
    // MARK: - Navigation
    
    private func navigationToPhotoPreview(indexPath: IndexPath) {
        
        detailCollectionView.deselectItem(at: indexPath, animated: true)
        
        let photoPreviewStoryboard = UIStoryboard(name: "PhotoPreview", bundle: nil)
        let photoPreviewVC = photoPreviewStoryboard.instantiateViewController(identifier: "photoPreview") as! PhotoPreviewViewController
        
        photoPreviewVC.title = DateFormatterService.instance.dateToString(date: adventures[indexPath.row].date!)
        photoPreviewVC.navigationController?.navigationBar.prefersLargeTitles = false
        photoPreviewVC.navigationItem.largeTitleDisplayMode = .never
        photoPreviewVC.adventures = self.adventures
        photoPreviewVC.images = self.images
        photoPreviewVC.initialIndexPath = indexPath
        photoPreviewVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(photoPreviewVC, animated: true)
    }

    // MARK: - Button Action
    
    @IBAction func selectTapped(_ sender: Any) {
        condition = (condition == .unselect) ? .selected : .unselect; setCanceledUI()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                CoreDataService.instance.updateParentAlbum(adventure: adventures[key.row], album: nil)
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name("updatePhotoAlbum"), object: nil)
        
        dictionarySelectedIndexPath.removeAll()
        checkSelectedCell()
        loadAdventures()
    }
    
}

// MARK: - Collection View Delegate

extension DetailAlbumViewController: UICollectionViewDelegate {
    
    
}

// MARK: - Collection View Data Source

extension DetailAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adventures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! DetailCollectionViewCell
        
        cell.detailImageView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.3).isActive = true
        cell.detailImageView.heightAnchor.constraint(equalToConstant: view.frame.size.width * 0.3).isActive = true
        cell.layer.cornerRadius = 10
        
        cell.detailImageView.image = FileManagerService.instance.getImageFromStorage(imageName: adventures[indexPath.row].photo!)
        
        images.append(cell.detailImageView.image!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch condition {
        case .unselect:
            navigationToPhotoPreview(indexPath: indexPath)
            break
        case .selected:
            deleteBarButton.tintColor = nil
            deleteBarButton.isEnabled = true
            dictionarySelectedIndexPath[indexPath] = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if condition == .selected {
            dictionarySelectedIndexPath[indexPath] = false
        }
        
        checkSelectedCell()
    }
    
}

// MARK: - Delegate Flow Layout

extension DetailAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = view.frame.size.width * 0.3
        let width = view.frame.size.width * 0.3
        
        return CGSize(width: width, height: height)
    }
}
