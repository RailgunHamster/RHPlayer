//
//  PictureList.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/10.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import Foundation

class PictureList {
    required init(_ dir: Directory) {
        self.dir = dir
        self.load()
    }
    
    let dir: Directory
    
    private var list = [Picture]()
    
    var count: Int {
        return list.count
    }

    var index = 0 {
        didSet {
            guard index >= 0 && index < self.count else {
                index = oldValue
                return
            }
        }
    }
    
    var now: Picture {
        return list[self.index]
    }
    
    subscript(index: Int) -> Picture {
        guard index >= 0 && index < self.count else {
            fatalError("超出范围")
        }
        
        return list[index]
    }
    
    func legal(index: Int) -> Bool {
        return index >= 0 && index < self.count
    }
    
    func setIndex(with: Picture) {
        guard let index = list.index(where: { $0.path == with.path }) else {
            fatalError("应该能找到这张图片")
        }
        
        self.index = index
    }
}

extension PictureList {
    fileprivate func load() {
        for file in dir {
            if file.type == .picture {
                guard let picture = file as? Picture else {
                    fatalError("error type of file when loading pictures")
                }
                
                list.append(picture)
            }
        }
    }
}
