import UIKit

class AllAdventuresViewController: UIViewController {
    @IBOutlet weak var adventuresCollectionView: UICollectionView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
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
        
        setInitialUI()
        
        AudioService.instance.playBackgroundMusic(sound: "forest", type: "mp3")
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMoveToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMoveToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        adventuresCollectionView.delegate = self
        adventuresCollectionView.dataSource = self
        
        loadAdventures()
        NotificationCenter.default.addObserver(self, selector: #selector(selectorLoadAdventures), name: .adventureAdded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
    }
    
    @objc func selectorLoadAdventures() {
        loadAdventures()
    }
    
    private func loadAdventures() {
        images.removeAll()
        
        if let tempAdventures = CoreDataService.instance.fetchAllAdventures() {
            adventures = tempAdventures
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.adventuresCollectionView.reloadData()
        }
    }
    
    // MARK: - Audio Action
    
    @objc func appMoveToBackground() {
        AudioService.instance.pauseMusic()
    }
    
    @objc func appMoveToForeground() {
        AudioService.instance.resumeMusic()
    }
}

// MARK: - Layouts

extension AllAdventuresViewController {
    
    private func setInitialUI() {
        leftBarButton.tintColor = .clear
        leftBarButton.isEnabled = false
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
        leftBarButton.tintColor = .clear
        leftBarButton.isEnabled = false
        adventuresCollectionView.allowsMultipleSelection = false
        self.tabBarController!.tabBar.items?.forEach { $0.isEnabled = true }
    }
    
    private func selectedCondition() {
        rightBarButton.title = "Cancel"
        adventuresCollectionView.allowsMultipleSelection = true
        self.tabBarController!.tabBar.items?.forEach { $0.isEnabled = false }
    }
    
    private func setCanceledUI() {
        dictionarySelectedIndexPath.removeAll()
        
        guard let selectedItems = adventuresCollectionView.indexPathsForSelectedItems else { return }
        
        for indexPath in selectedItems {
            adventuresCollectionView.deselectItem(at: indexPath, animated:true)
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
            leftBarButton.tintColor = .clear
            leftBarButton.isEnabled = false
        }
    }
}

// MARK: - Navigation

extension AllAdventuresViewController {
    private func navigationToPhotoPreview(indexPath: IndexPath) {
        adventuresCollectionView.deselectItem(at: indexPath, animated: true)
        
        let photoPreviewStoryboard = UIStoryboard(name: StoryboardId.PhotoPreview, bundle: nil)
        let photoPreviewVC = photoPreviewStoryboard.instantiateViewController(identifier: VCId.photoPreview) as PhotoPreviewViewController
        
        photoPreviewVC.title = DateFormatterService.instance.dateToString(date: adventures[indexPath.row].date!)
        photoPreviewVC.adventures = self.adventures
        photoPreviewVC.images = self.images
        photoPreviewVC.initialIndexPath = indexPath
        photoPreviewVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(photoPreviewVC, animated: true)
    }
}
    
// MARK: - Button Actions
   
extension AllAdventuresViewController {
    @IBAction func selectTapButton(_ sender: Any) {
        condition = (condition == .unselect) ? .selected : .unselect; setCanceledUI()
    }
    
    @IBAction func removeTapButton(_ sender: Any) {

        for (key, value) in dictionarySelectedIndexPath {
            if value {

                FileManagerService.instance.deleteImageInStorage(imageName: adventures[key.row].photo!)
                CoreDataService.instance.deleteAdventure(adventure: adventures[key.row])
            }
        }

        dictionarySelectedIndexPath.removeAll()
        checkSelectedCell()
        loadAdventures()
    }
}

// MARK: - Collection View Delegate

extension AllAdventuresViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch condition {
            case .unselect:
                navigationToPhotoPreview(indexPath: indexPath)
                break
            case .selected:
                leftBarButton.tintColor = nil
                leftBarButton.isEnabled = true
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

// MARK: Collection View Data Source

extension AllAdventuresViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        adventures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = adventuresCollectionView.dequeueReusableCell(withReuseIdentifier: CellId.imageCell, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let photoID = adventures[indexPath.row].photo else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(image: FileManagerService.instance.getImageFromStorage(imageName: photoID) ?? UIImage(named: "question-mark")!)
        images.append(cell.imageView.image ?? UIImage(named: "question-mark")!)
        
        return cell
    }
    
}

// MARK: - Collection View Flow Layout

extension AllAdventuresViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.width * 0.3
        let width = view.frame.size.width
        
        return CGSize(width: width * 0.3, height: height)
    }
}
