//
//  AlbumCollectionViewCell.swift
//  Myres
//
//  Created by Luis Genesius on 02/05/21.
//

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
}
