//
//  CoreDataService.swift
//  Myres
//
//  Created by Luis Genesius on 29/04/21.
//

import Foundation
import CoreData
import UIKit

public class CoreDataService {
    
    // Singleton pattern
    public static let instance = CoreDataService()
    
    public let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public func fetchAllAdventures() -> [Adventure]? {
        
        do {
            let request = Adventure.fetchRequest() as NSFetchRequest<Adventure>
            let sort = NSSortDescriptor(key: "date", ascending: true)
            
            request.sortDescriptors = [sort]
            
            return try context.fetch(request)
        }
        catch {
            print("ERROR Fetch Request \(error)")
        }
        
        return nil
    }
    
    public func fetchAllAlbums() -> [Album]? {
        
        do {
            let request = Album.fetchRequest() as NSFetchRequest<Album>
            
            return try context.fetch(request)
        }
        catch {
            print("ERROR Fetch Request \(error)")
        }
        
        return nil
    }
    
    public func saveAdventure(title: String, location: String, story: String, date: Date, photo: String, album: Album?) -> Bool {
        
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
        }
        catch {
            bool = false
            print(error.localizedDescription)
        }
        
        return bool
    }
    
    public func deleteAdventure(adventure: Adventure) {
        self.context.delete(adventure)
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    public func saveAlbum(title: String) {
        let newAlbum = Album(context: self.context)
        
        newAlbum.title = title
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    public func fetchAdventuresBasedOnAlbum(album: Album) -> [Adventure]? {
        do {
            let request = Adventure.fetchRequest() as NSFetchRequest<Adventure>
            request.predicate = NSPredicate(format: "parentAlbum.title MATCHES %@", album.title!)
            let sort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sort]
            
            return try context.fetch(request)
        }
        catch {
            print("ERROR Fetch Request \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func deleteAlbum(album: Album) {
        self.context.delete(album)
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateParentAlbum(adventure: Adventure, album: Album?) {
        
        let currentAdventure = adventure
        
        currentAdventure.parentAlbum = album
        
        do {
            try self.context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateAdventure(adventure: Adventure, title: String, location: String, story: String, album: Album?) {
        
        let currentAdventure = adventure
        
        currentAdventure.title = title
        currentAdventure.location = location
        currentAdventure.story = story
        
        currentAdventure.parentAlbum = album
        NotificationCenter.default.post(name: Notification.Name("updatePhotoAlbum"), object: nil)
        
        do {
            try self.context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
