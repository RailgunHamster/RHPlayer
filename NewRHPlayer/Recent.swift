//
//  Recent.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/12/21.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import CoreData
import UIKit

class Recent {
    private init() {
        OperationQueue().addOperation {
            self.load()
        }
    }
    
    static let shared = Recent()
    
    var delegate: RecentDelegate?
    
    private var contents = [NSManagedObject]()
    
    private lazy var fileContext: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: Recent.model)
        container.loadPersistentStores { (storeDescription, error) in
            if let e = error {
                fatalError("error when load persistent stores:\n\(e)")
            }
        }
        return container.viewContext
    }()
    
    func append(file: File) {
        let index = self.contents.index {
            guard let path = $0.value(forKey: Recent.path) as? String else {
                fatalError("Entity \"path\" type error when append a file")
            }
            
            return path == file.relativePath
        }
        
        if let contentIndex = index {
            self.update(index: contentIndex, willSave: true)
        } else {
            self.add(relativePath: file.relativePath, willSave: true)
        }
        
        self.sort()
        self.delegate?.reload()
    }
    
    func removeAll() {
        self.deleteAll()
        self.contents.removeAll()
        self.delegate?.reload()
    }
    
    var count: Int {
        return self.contents.count
    }
    
    subscript(index: Int) -> File {
        guard index >= 0 && index < self.count else {
            fatalError("对Recent访问越界, \(index)/\(self.count)")
        }
        
        return self.get(index: index)
    }
    
    func date(index: Int) -> Date {
        guard let date = self.contents[index].value(forKey: "date") as? Date else {
            fatalError("error when get from \(self.contents)")
        }
        
        return date
    }
}

extension Recent {
    private static let model = "FileModel"
    private static let path = "path"
    private static let date = "date"
}

extension Recent {
    fileprivate func load() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Recent.model)
        
        guard let result = (try? fileContext.fetch(fetchRequest)) as? [NSManagedObject] else {
            fatalError("error when load recent objects")
        }
        
        self.contents = result
        self.sort()
    }
    
    fileprivate func save() {
        do {
            try fileContext.save()
        } catch {
            fatalError("error when save recent objects")
        }
    }
    
    fileprivate func add(relativePath: String, willSave: Bool) {
        guard let entity = NSEntityDescription.entity(forEntityName: Recent.model, in: fileContext) else {
            fatalError("error when create an entity")
        }
        
        let file = NSManagedObject(entity: entity, insertInto: fileContext)
        file.setValue(relativePath, forKey: Recent.path)
        file.setValue(self.localDate, forKey: Recent.date)
        
        self.contents.append(file)
        
        if willSave {
            self.save()
        }
    }
    
    fileprivate var localDate: Date {
        let hour = 60.0 * 60.0
        return Date().addingTimeInterval(8 * hour)  // 东八区
    }
    
    fileprivate func update(index: Int, willSave: Bool) {
        self.contents[index].setValue(self.localDate, forKey: "date")
        
        if willSave {
            self.save()
        }
    }
    
    fileprivate func deleteAll() {
        let count = self.count
        for index in 0..<count {
            self.delete(index: count - index - 1, willSave: false)
        }
        
        self.save()
    }
    
    fileprivate func delete(index: Int, willSave: Bool) {
        fileContext.delete(self.contents[index])
        
        self.contents.remove(at: index)
        
        if willSave {
            self.save()
        }
    }
    
    fileprivate func get(index: Int) -> File {
        guard let relativePath = self.contents[index].value(forKey: "path") as? String else {
            fatalError("error when get from \(self.contents)")
        }
        
        return File.instance(relative: relativePath)
    }
    
    fileprivate func sort() {
        self.contents.sort {
            guard let leftDate = $0.value(forKey: "date") as? Date,
                let rightDate = $1.value(forKey: "date") as? Date else {
                    fatalError("date not found")
            }
            
            return leftDate > rightDate
        }
    }
}
