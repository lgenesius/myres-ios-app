import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var detailImageView: UIImageView!
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
    
    func configureCell(image: UIImage?) {
        self.detailImageView.image = image
        self.detailImageView.frame = contentView.frame
        
        self.layer.cornerRadius = 10
    }
}
