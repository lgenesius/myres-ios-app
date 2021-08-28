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
