//
//  StorageManager.swift
//  Notes
//
//  Created by Анатолий Миронов on 02.02.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    func save(_ text: String, completion: ((Note) -> Void)?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: viewContext) else { return }
        guard let note = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Note else { return }
        note.text = text
        if let completion = completion {
            completion(note)
        }
        saveContext()
    }
    
    func fetchData(completion: (Result<[Note], Error>) -> Void) {
        let fetchRequest = Note.fetchRequest()

        do {
            let notes = try viewContext.fetch(fetchRequest)
            completion(.success(notes))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func edit(_ note: Note, newText: String) {
        note.text = newText
        saveContext()
    }

    func delete(_ note: Note) {
        viewContext.delete(note)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
