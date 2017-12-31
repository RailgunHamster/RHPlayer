//
//  Video.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/7.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import AVKit

class Video: File {
    override lazy var picture: UIImage = {
        guard let image = AVPlayerViewController.shotCut(of: path) else {
            return #imageLiteral(resourceName: "video")
        }
        return image
    }()
    
    override var isPictureLoadingNeedsTime: Bool {
        return true
    }
    
    override var type: File.type {
        return File.type.video
    }
    
    lazy var player: AVPlayer = {
        return AVPlayer(url: URL(fileURLWithPath: path))
    }()
    
    override func prepare(for viewController: UIViewController) {
        if let detailController = viewController as? DetailController {
            detailController.source = self
            return
        }
        
        guard let videoController = viewController as? AVPlayerViewController else {
            fatalError("没有前往一个AVPlayerController, \(viewController)")
        }
        
        videoController.player = player
    }
}
