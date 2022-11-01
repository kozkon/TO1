//
//  DataStoreManager.swift
//  TO
//
//  Created by Константин Козлов on 02.02.2022.
//


import CoreData
import UIKit

class DataStoreManager{
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TO")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    lazy var viewContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func fetchShopsData()->([Shop]){
        
        let context = viewContext
        
        do{
            let shops = try context.fetch(Shop.fetchRequest())
            return shops
        }
        catch let error {
            print(error.localizedDescription)
            let shops: [Shop] = []
            return shops
        }
    }
    
    
    func saveShop(with context: NSManagedObjectContext, name: String){
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Shop", in: context) else {return}
        guard let shop = NSManagedObject(entity: entity, insertInto: context) as? Shop else {return}
        
        shop.name = name
        saveContext()
    }
    
    
    func createImage(with context: NSManagedObjectContext)->(Images?){
        guard let entity = NSEntityDescription.entity(forEntityName: "Images", in: context) else {return nil}
        guard let image = NSManagedObject(entity: entity, insertInto: context) as? Images else {return nil}
        
        return image
    }
    
    
    func fetchShops()->([Shop]){
        
        let fetchRequest: NSFetchRequest<Shop> = Shop.fetchRequest()
        
        do{
            let shops = try viewContext.fetch(fetchRequest)
            return shops
        }catch let error{
            print(error.localizedDescription)
            let shops: [Shop] = []
            return shops
        }
    }
    
    
    func fetchShop(name: String)->[Shop]{
        var shop: [Shop]!
        
        let request = Shop.fetchRequest() as NSFetchRequest<Shop>
        let predicate = NSPredicate(format: "%K == %@", "name", name)
        request.predicate = predicate
        
        do{
            shop = try viewContext.fetch(request)
            
        }catch let error{
            print(error.localizedDescription)
        }
        return shop
    }
    
    
    func fetchPhotoFromShop(shopName: String)->[Photo]{
        var photos: [Photo]!
        
        let request = Photo.fetchRequest() as NSFetchRequest<Photo>
        
        let predicate = NSPredicate(format: "%K == %@", "shop.name", shopName)
        
        request.predicate = predicate
        
        do{
            photos = try viewContext.fetch(request)
        }catch let error{
            print(error.localizedDescription)
            
        }
        
        return photos
    }
    
    
    func fetchImagesFromPhoto(photo: Photo)->([Images]){
        var images: [Images]!
        
        let request = Images.fetchRequest() as NSFetchRequest<Images>
        
        let predicate = NSPredicate(format: "%K == %@", "photo", photo)
        request.predicate = predicate
        
        do{
            images = try viewContext.fetch(request)
        }catch let error{
            print(error.localizedDescription)
        }
        return images
    }
    
    
    func deleteDataObject(object: NSManagedObject){
        
        viewContext.delete(object)
        saveContext()
    }
}







