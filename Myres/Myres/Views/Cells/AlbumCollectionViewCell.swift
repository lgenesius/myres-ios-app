import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var highlightIndicator: UIView!
    @IBOutlet weak var selectedIndicator: UIImageView!
    
    override var isHighlighted: Bool {
        didSet {
            highlightIndicator.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            highlightIndicator.isHidden = !isSelected
            selectedIndicator.isHidden = !isSelected
        }
    }
    
    func configureCell(imageID: String?, title: String?) {
        if let firstImage = imageID {
            albumImageView.image = FileManagerService.instance.getImageFromStorage(imageName: firstImage)
        } else {
            albumImageView.image = UIImage(named: "question-mark")
        }
        albumLabel.text = title
        
        modifyLayouts()
    }
    
    func modifyLayouts() {
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.label.cgColor
    }
}
