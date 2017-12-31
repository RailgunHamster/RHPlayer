//
//  Picture.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/7.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class Picture: File {
    override lazy var picture: UIImage = {
        guard let image = UIImage(contentsOfFile: path) else {
            return #imageLiteral(resourceName: "image")
        }
        return image
    }()
    
    override var isPictureLoadingNeedsTime: Bool {
        return true
    }
    
    override var type: File.type {
        return File.type.picture
    }
}
