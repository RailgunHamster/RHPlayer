//
//  Text.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/7.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class Text: File {
    override lazy var picture: UIImage = {
        return #imageLiteral(resourceName: "book")
    }()
    
    override var type: File.type {
        return File.type.text
    }
}

