//
//  CoreDataSavingSupport.swift
//  WebsiteFilter
//
//  Created by Екатерина Токарева on 06/02/2023.
//

import Foundation
import CoreData
import UIKit

struct CoreDataSavingSupport {
    func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        
    }
}
