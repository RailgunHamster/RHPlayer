//
//  File.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/6.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class File {
    required init(_ path: String) {
        self.path = path
    }
    
    let path: String
    
    private var __parent: Directory?
    
    var parent: Directory {
        set{
            self.__parent = newValue
        }
        get{
            if let p = self.__parent {
                return p
            } else if self.path == Directory.homeDir {
                    return self as! Directory
            } else {
                let p = Directory(self.parentPath)
                self.__parent = p
                p.load()
                return p
            }
        }
    }
    
    var type: File.type {
        return File.type.none
    }
    
    var relativePath: String {
        let start = self.path.finalSubStringIndex(by: Directory.Path.user.path, leading: false)
        return String(self.path[start...])
    }
    
    lazy var picture: UIImage = {
        return #imageLiteral(resourceName: "file")
    }()
    
    var isPictureLoadingNeedsTime: Bool {
        return false
    }
    
    lazy var name: String = {
        let end = self.fullname.finalSubStringIndex(by: ".", leading: true)
        return String(self.fullname[..<end])
    }()
    
    lazy var ext: String = {
        let start = self.fullname.finalSubStringIndex(by: ".", leading: false)
        return String(self.fullname[start...])
    }()
    
    lazy var fullname: String = {
        return FileManager.default.displayName(atPath: self.path)
    }()
    
    static func instance(relative: String) -> File {
        return File.instance(path: Directory.Path.user.path + relative)
    }
    
    static func instance(path: String) -> File {
        let fileClass = File.type.getType(of: path).fileClass
        return fileClass.init(path)
    }
    
    func prepare(for viewController: UIViewController) {
        guard let fileViewController = viewController as? FileViewController else {
            fatalError("没有前往一个FileViewController, \(viewController)")
        }
        
        fileViewController.source = self
    }
    
    enum type: String {
        case directory = "Directory"
        case video = "Video"
        case text = "Text"
        case picture = "Picture"
        case zip = "Zip"
        case none = "none"
        
        var form: String {
            switch self {
            case .directory, .zip:
                return "folderlike"
            default:
                return "videolike"
            }
        }
        
        var controllerID: String {
            return rawValue
        }
        
        var fileClass: File.Type {
            guard let namespace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else {
                fatalError("无法获取当前名空间")
            }
            
            let type = NSClassFromString(namespace + "." + self.rawValue) as? File.Type
            return type ?? File.self
        }
        
        static func getType(of path: String) -> File.type {
            //获取文件属性
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
                fatalError("文件应该有属性")
            }
            //获取文件类型信息
            guard let type = attributes[.type] as? FileAttributeType else {
                fatalError("文件应该有类型信息")
            }
            
            switch type {
            case FileAttributeType.typeDirectory:
                return .directory
            case FileAttributeType.typeRegular:
                let index = path.finalSubStringIndex(by: ".", leading: false)
                return .extType(of: String(path[index...]))
            default:
                return .none
            }
        }
        
    }
}

extension File.type {
    fileprivate static func extType(of ext: String) -> File.type {
        switch ext.lowercased() {
        case "jpg", "png":
            return .picture
        case "mp4":
            return .video
        case "txt", "php", "swift", "java", "py", "c", "cpp", "json":
            return .text
        case "zip":
            return .zip
        default:
            return .none
        }
    }
}

extension File {
    fileprivate var parentPath: String {
        let end = self.path.finalSubStringIndex(by: "/", leading: true)
        return String(self.path[..<end])
    }
}
