import Foundation
import CoreData
import UIKit

class CoreDataService {
    static let instance = CoreDataService()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchAllAdventures() -> [Adventure]? {
        let request = Adventure.fetchRequest() as NSFetchRequest<Adventure>
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            return try context.fetch(request)
        } catch {
            print("ERROR Fetch Request \(error)")
        }
        
        return nil
    }
    
    func fetchAllAlbums() -> [Album]? {
        let request = Album.fetchRequest() as NSFetchRequest<Album>
        
        do {
            return try context.fetch(request)
        } catch {
            print("ERROR Fetch Request \(error)")
        }
        
        return nil
    }
    
    func saveAdventure(title: String, location: String, story: String, date: Date, photo: String, album: Album?) -> Bool {
        
        let newAdventure = Adventure(context: self.context)
        
        newAdventure.title = title
        newAdventure.location = location
        newAdventure.story = story
        newAdventure.date = date
        newAdventure.photo = photo
        
        if let album = album {
            newAdventure.parentAlbum = album
            
            NotificationCenter.default.post(name: Notification.Name("updatePhotoAlbum"), object: nil)
        }
        
        var bool = true
        
        do {
            try context.save()
        } catch {
            bool = false
            print(error.localizedDescription)
        }
        
        return bool
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteAdventure(adventure: Adventure) {
        self.context.delete(adventure)
        saveData()
    }
    
    public func saveAlbum(title: String) {
        let newAlbum = Album(context: self.context)
        newAlbum.title = title
        saveData()
    }
    
    public func fetchAdventuresBasedOnAlbum(album: Album) -> [Adventure]? {
        let request = Adventure.fetchRequest() as NSFetchRequest<Adventure>
        request.predicate = NSPredicate(format: "parentAlbum.title MATCHES %@", album.title!)
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            return try context.fetch(request)
        }
        catch {
            print("ERROR Fetch Request \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func deleteAlbum(album: Album) {
        self.context.delete(album)
        saveData()
    }
    
    public func updateParentAlbum(adventure: Adventure, album: Album?) {
        let currentAdventure = adventure
        currentAdventure.parentAlbum = album
        saveData()
    }
    
    public func updateAdventure(adventure: Adventure, title: String, location: String, story: String, album: Album?) {
        
        let currentAdventure = adventure
        
        currentAdventure.title = title
        currentAdventure.location = location
        currentAdventure.story = story
        
        currentAdventure.parentAlbum = album
        NotificationCenter.default.post(name: Notification.Name("updatePhotoAlbum"), object: nil)
        saveData()
    }
}
