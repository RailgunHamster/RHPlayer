//
//  Zip.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/12/5.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit
import SSZipArchive

class Zip: File {
    override lazy var picture: UIImage = {
        return #imageLiteral(resourceName: "zip")
    }()
    
    override var type: File.type {
        return File.type.zip
    }
    
    var password: String?
    var dstdir: Directory?
    private lazy var dst: String = {
        return parent.path + "/" + self.name + "_" + self.ext
    }()
    
    func unzip() -> State {
        guard self.dstdir == nil else {
            return State.success
        }
        guard !FileManager.default.fileExists(atPath: self.dst) else {
            dstdir = Directory(dst)
            dstdir?.parent = self.parent
            return State.exist
        }
        //create directory
        do {
            try FileManager.default.createDirectory(atPath: self.dst, withIntermediateDirectories: false, attributes: nil)
        } catch {
            return State.fail
        }
        do {
            try SSZipArchive.unzipFile(atPath: self.path, toDestination: self.dst, overwrite: false, password: password)
            if UserDefaults.standard.bool(forKey: SettingsController.unzipDelete) {
                let _ = self.parent.delete(file: self)
            }
        } catch {
            //delete empty directory
            do {
                try FileManager.default.removeItem(atPath: self.dst)
            } catch {
                return State.fail
            }
            return State.password
        }
        dstdir = Directory(dst)
        dstdir?.parent = self.parent
        return State.success
    }
    
    enum State {
        case fail
        case password
        case success
        case exist
    }
}
