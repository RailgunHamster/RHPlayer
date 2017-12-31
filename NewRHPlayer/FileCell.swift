//
//  FileCell.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/4.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class FileCell: UICollectionViewCell {
    var loadingQueue: OperationQueue?
    var file: File? {
        didSet {
            update()
        }
    }
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel! {
        didSet {
            //约束了此UILabel一行最大的长度，若超过则会换行
            title.preferredMaxLayoutWidth = title.frame.width * 2
        }
    }
    
    internal func update() {
        guard let f = file else {
            fatalError("file not found")
        }
        guard let loading = loadingQueue else {
            fatalError("loading queue not found")
        }

        title.text = f.name

        // load image asynchronized or straightly
        if f.isPictureLoadingNeedsTime {
            loading.addOperation {
                let image = f.picture
                OperationQueue.main.addOperation {
                    self.picture.image = image
                }
            }
        } else {
            picture.image = f.picture
        }
    }
}
