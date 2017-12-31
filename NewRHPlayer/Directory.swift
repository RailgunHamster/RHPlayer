//
//  Directory.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/6.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit
import Foundation

class Directory: File {
    convenience init() {
        self.init(Directory.homeDir)
    }
    
    override var type: File.type {
        return File.type.directory
    }
    
    override lazy var picture: UIImage = {
        return #imageLiteral(resourceName: "folder")
    }()
    
    static let homeDir = Path.user.path
    
    var count: Int {
        return files.count
    }
    
    private var __loaded = false
    
    var loaded: Bool {
        return self.__loaded
    }
    
    func append(file: File) {
        files.append(file)
    }
    
    func remove(at: Int) {
        files.remove(at: at)
    }
    
    func removeAll() {
        files.removeAll()
    }
    
    func delete(file: File) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: file.path)
        } catch {
            return false
        }
        
        self.load()
        return true
    }
    
    func rename(file: File, name: String) -> Bool {
        do {
            let path = file.parent.path
            
            try FileManager.default.moveItem(atPath: file.path, toPath: path + "/" + name)
        } catch {
            return false
        }
        
        self.load()
        return true
    }
    
    var isHome: Bool {
        return self.path == Directory.homeDir
    }
    
    enum Path {
        case user
        case setting
        var path: String {
            switch self {
            case .user:
                return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            case .setting:
                return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            }
        }
    }
    
    private var files = [File]()
    
    func load() {
        // clear
        self.removeAll()
        
        // 获取文件夹内文件内容
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self.path) else {
            fatalError("获取文件夹内容失败: \(self.path)")
        }
        
        contents.sorted().forEach {
            content in
            let file = File.instance(path: self.path + "/" + content)
            file.parent = self
            guard file.name.count != 0 else {
                return
            }
            self.append(file: file)
        }
        
        self.__loaded = true
    }
    
    subscript(index: Int) -> File {
        guard index >= 0 && index < self.count else {
            fatalError("对Files访问越界, \(index)/\(self.count)")
        }
        
        return self.files[index]
    }
}

extension Directory: Sequence {
    struct Iterator: IteratorProtocol {
        let dir: Directory
        var count = 0
        
        init(_ dir: Directory) {
            self.dir = dir
        }
        
        mutating func next() -> File? {
            guard count < dir.count else {
                return nil
            }
            let file = dir[count]
            count += 1
            return file
        }
    }
    
    func makeIterator() -> Directory.Iterator {
        return Iterator(self)
    }
}
