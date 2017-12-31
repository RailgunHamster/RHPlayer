//
//  Extension.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/7.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import Foundation
import AVKit

extension Notification {
    class RHPlayer {
        static let OpenFile = Notification.Name("OpenFile")
        static let DeleteFile = Notification.Name("DeleteFile")
        static let RenameFile = Notification.Name("RenameFile")
        static let ClearCache = Notification.Name("ClearCache")
        static let ClearCacheFinish = Notification.Name("ClearCacheFinish")
    }
}

extension String {
    func finalSubStringIndex(by str: String, leading: Bool) -> Index {
        let range = self.range(of: str, options: .backwards, range: nil, locale: nil)
        let from = (leading ? range?.lowerBound : range?.upperBound) ?? self.endIndex
        return from
    }
}

extension AVPlayerViewController {
    static func shotCut(of video: String) -> UIImage? {
        let videoURL = URL(fileURLWithPath: video)
        let asset = AVAsset(url: videoURL)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0, 600)
        var actualTime = CMTimeMake(0, 0)
        guard let imageRef = try? gen.copyCGImage(at: time, actualTime: &actualTime) else {
            return nil
        }
        let img = UIImage(cgImage: imageRef)
        return img
    }
}
