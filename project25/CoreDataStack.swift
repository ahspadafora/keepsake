//
//  CoreDataStack.swift
//  project25
//
//  Created by Amber Spadafora on 9/25/17.
//  Copyright © 2017 Amber Spadafora. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    private let modelName: String
    init(modelName: String){
        self.modelName = modelName
    }
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Unresolved error: \(error), \(error.userInfo)")
        }
    }
    
    func addPhoto(image: Data) {
        do {
            let coreDataImage = Picture(context: managedContext)
            coreDataImage.imageData = NSData(data: image)
            try managedContext.save()
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func fetchImages(callback: @escaping ([Picture]?) -> Void) {
        let imageFetch: NSFetchRequest<Picture> = Picture.fetchRequest()
        do {
            let results = try managedContext.fetch(imageFetch)
            guard results.count > 0 else {
                print("There are no images saved in core data")
                return
            }
            callback(results)
        }
        catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
}
