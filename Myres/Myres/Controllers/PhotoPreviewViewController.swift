import UIKit

class PhotoPreviewViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    // MARK: - Attributes
    
    public var adventures = [Adventure]()
    public var images = [UIImage]()
    
    var backgrounds = [String]()
    var  initialIndexPath = IndexPath()
    var insideIndexPath = IndexPath()
    private var firstTime = true
    
    private var bottomCardVC: BottomCardViewController!
    private var visualEffectView: UIVisualEffectView!
    
    private let cardHeight: CGFloat = 520
    private let cardHandleAreaHeight: CGFloat = 102
    
    private var cardVisible = false
    private var nextState: Mode.CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    private var runningAnimation = [UIViewPropertyAnimator]()
    private var animationProgressInterrupt: CGFloat = 0
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialNavigationBar()
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.reloadData()
        photoCollectionView.backgroundColor = .clear
        
        DispatchQueue.main.async {
            self.photoCollectionView.scrollToItem(at: self.initialIndexPath, at: .centeredHorizontally, animated: false)
        }
        
        setVisualEffect()
        setCardUI()
        setPanGesture()
        insideIndexPath = initialIndexPath
        backgroundImageView.image = images[initialIndexPath.row]
        changeCardText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.backgroundColor = nil
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.sizeToFit()
    }
}

// MARK: - Layouts

extension PhotoPreviewViewController {
    
    private func setInitialNavigationBar() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    private func changeBackgroundImage() {
        self.backgroundImageView.image = images[insideIndexPath.row]
    }
    
    private func changeTitle() {
        let currentCellDate = DateFormatterService.instance.dateToString(date: adventures[insideIndexPath.row].date!)
        
        if self.title != currentCellDate {
            self.title = currentCellDate
        }
        
    }
    
    private func setVisualEffect() {
        visualEffect.effect = UIBlurEffect(style: .regular)
        visualEffect.alpha = 0.8
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        visualEffectView.isUserInteractionEnabled = false
        self.view.addSubview(visualEffectView)
    }
    
    private func setCardUI() {
        bottomCardVC = BottomCardViewController(nibName: "BottomCardViewController", bundle: nil)
        self.addChild(bottomCardVC)
        self.view.addSubview(bottomCardVC.view)

        self.bottomCardVC.titleLabel.alpha = 0
        self.bottomCardVC.locationLabel.alpha = 0
        self.bottomCardVC.storyLabel.alpha = 0
        
        bottomCardVC.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        bottomCardVC.view.layer.cornerRadius = 12
        bottomCardVC.view.clipsToBounds = true
    }
    
    private func changeCardText() {
        bottomCardVC.titleLabel.text = adventures[insideIndexPath.row].title
        bottomCardVC.locationLabel.text = "Location: \(adventures[insideIndexPath.row].location!)"
        bottomCardVC.storyLabel.text = adventures[insideIndexPath.row].story
    }
    
}

// MARK: - Gesture

extension PhotoPreviewViewController {
    
    private func setPanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PhotoPreviewViewController.handleCardPan(recognizer:)))
        
        bottomCardVC.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.bottomCardVC.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueTransition()
        default:
            break
        }
    }
    
}

// MARK: - Animations

extension PhotoPreviewViewController {
    
    private func animateTransition(state: Mode.CardState, duration: TimeInterval) {
        if runningAnimation.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                    case .expanded:
                        self.showLabel()
                        self.bottomCardVC.view.frame.origin.y = self.view.frame.height - self.cardHeight
                    case .collapsed:
                        self.hideLabel()
                        self.bottomCardVC.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            frameAnimator.addCompletion { (_) in
                self.cardVisible = !self.cardVisible
                self.runningAnimation.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimation.append(frameAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .regular)
                    self.visualEffectView.isUserInteractionEnabled = true
                case .collapsed:
                    self.visualEffectView.effect = nil
                    self.visualEffectView.isUserInteractionEnabled = false
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimation.append(blurAnimator)
        }

    }
    
    private func startTransition(state: Mode.CardState, duration: TimeInterval) {
        if runningAnimation.isEmpty {
            animateTransition(state: state, duration: duration)
        }
        
        for animator in runningAnimation {
            animator.pauseAnimation()
            animationProgressInterrupt = animator.fractionComplete
        }
    }
    
    private func updateTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimation {
            animator.fractionComplete = fractionCompleted + animationProgressInterrupt
        }
    }
    
    private func continueTransition() {
        for animator in runningAnimation {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    private func showLabel() {
        UIView.animate(withDuration: 0.25) {
            self.bottomCardVC.titleLabel.alpha = 1
            self.bottomCardVC.locationLabel.alpha = 1
            self.bottomCardVC.storyLabel.alpha = 1
        }
    }
    
    private func hideLabel() {
        UIView.animate(withDuration: 0.25) {
            self.bottomCardVC.titleLabel.alpha = 0
            self.bottomCardVC.locationLabel.alpha = 0
            self.bottomCardVC.storyLabel.alpha = 0
        }
    }
}

// MARK: - Sheet

extension PhotoPreviewViewController {
    
    private func presentActionSheet() {
        AlertDisplayer.instance.showEditPhoto(vc: self, title: "Choose Edit Action", message: "Do you want to update or share ?") { [weak self] action in
            guard let title = action.title else { return }
            if title == "Update" {
                self?.updateAdventure()
            } else if title == "Share" {
                self?.presentShareSheet()
            }
        }
    }
    
    private func presentShareSheet() {
        let image = images[insideIndexPath.row]
        
        let shareSheetVC = UIActivityViewController(activityItems: [
            image
        ], applicationActivities: nil)
        DispatchQueue.main.async { [weak self] in
            self?.present(shareSheetVC, animated: true, completion: nil)
        }
    }
    
    @objc func editTapped() {
        presentActionSheet()
    }
    
}

// MARK: - Navigation

extension PhotoPreviewViewController {
    
    private func updateAdventure() {
        guard let updateVC = storyboard?.instantiateViewController(identifier: VCId.updateVC) as? UpdateAdventureViewController else { return }
        
        updateVC.navigationItem.largeTitleDisplayMode = .never
        updateVC.title = "Update"
        updateVC.selectedAdventure = adventures[insideIndexPath.row]
        
        self.navigationController?.pushViewController(updateVC, animated: true)
    }
    
}

// MARK: - Collection View Delegate

extension PhotoPreviewViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard var centreCell = self.photoCollectionView.visibleCells.first else {return}
        let collectionViewCentre = photoCollectionView.bounds.size.width / 2.0
        for cell in photoCollectionView.visibleCells {
            let offset = photoCollectionView.contentOffset.x
            let closestCellDelta = abs(centreCell.center.x - collectionViewCentre - offset)
            let cellDelta = abs(cell.center.x - collectionViewCentre - offset)
            if (cellDelta < closestCellDelta){
                centreCell = cell
            }
        }
        
        let centreIndexPath = self.photoCollectionView.indexPath(for: centreCell)!
        
        if firstTime == true {
            firstTime = false
        } else {
            insideIndexPath = centreIndexPath
            changeTitle()
            changeCardText()
            changeBackgroundImage()
        }
    }

}

// MARK: - Collection View Data Source

extension PhotoPreviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adventures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: CellId.photoCell, for: indexPath) as? PhotoPreviewCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(image: images[indexPath.row])
        
        return cell
    }
    
}

// MARK: - Delegate Flow Layout

extension PhotoPreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frame = self.view.safeAreaLayoutGuide.layoutFrame

        return CGSize(width: frame.width, height: frame.height)
    }
    
}
