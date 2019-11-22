//
//  CoreDataStack.swift
//  UrlSessionLesson
//
//  Created by Юрий Нориков on 22.11.2019.
//  Copyright © 2019 Константин Богданов. All rights reserved.
//

import Foundation
import CoreData

internal final class CoreDataStack {
    
    static let shared: CoreDataStack = {
        let coreDataStack = CoreDataStack()
        return coreDataStack
    }()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        let group = DispatchGroup()
        
        persistentContainer = NSPersistentContainer(name: "Model")
        group.enter()
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            group.leave()
        }
        group.wait()
    }
    
    
}
