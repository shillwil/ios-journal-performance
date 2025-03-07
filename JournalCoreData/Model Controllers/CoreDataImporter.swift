//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
        
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        print("Starting sync!")
        self.context.perform {
            var identifiers: [String] = []
//            for entryRep in entries {
//                guard let identifier = entryRep.identifier else { continue }
//
//                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
//                if let entry = entry, entry != entryRep {
//                    self.update(entry: entry, with: entryRep)
//                } else if entry == nil {
//                    _ = Entry(entryRepresentation: entryRep, context: self.context)
//                }
            identifiers = entries.compactMap({ $0.identifier })
//            }
            
            if let fetchedEntries = self.fetchSingleEntryFromPersistentStore(with: identifiers, in: self.context) {
                for entryRep in entries {
                    guard let identifier = entryRep.identifier else { return }
                    
                    let entry = fetchedEntries.first(where: { $0.identifier == identifier })
                    if let entry = entry, entry != entryRep {
                        self.update(entry: entry, with: entryRep)
                    } else if entry == nil {
                        _ = Entry(entryRepresentation: entryRep, context: self.context)
                    }
                    
                }
            }
            
            completion(nil)
        }
        print("Ended sync!")
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifiers: [String], in context: NSManagedObjectContext) -> [Entry]? {
        
//        guard let identifiers = identifiers else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        
        var result: [Entry]? = nil
        do {
            result = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    let context: NSManagedObjectContext
}
