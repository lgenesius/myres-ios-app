import UIKit

class PhotoPreviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configureCell(image: UIImage?) {
        imageView.image = image
        backgroundColor = .clear
        imageView.backgroundColor = .clear
        
        imageView.frame = contentView.frame
    }
}
