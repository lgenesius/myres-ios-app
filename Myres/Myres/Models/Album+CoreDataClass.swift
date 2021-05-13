//
//  Album+CoreDataClass.swift
//  Myres
//
//  Created by Luis Genesius on 02/05/21.
//
//

import Foundation
import CoreData
import UIKit

@objc(Album)
public class Album: NSManagedObject {
    
    public func fetchFirstImageFromChild() -> String? {
        guard let photos = adventures?.allObjects as? [Adventure] else { return nil }
        return (photos.count > 0) ? photos[0].photo! : nil
    }
    
}
