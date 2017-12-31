//
//  RecentViewController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/12/21.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class RecentViewController: UICollectionViewController {
    
    var recent = Recent.shared
    
    public static let tabBarIndex = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Do any additional setup after loading the view.
        self.recent.delegate = self
        self.addObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clear(_ sender: UIButton) {
        self.clear()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return recent.count
    }
    
    private var loadingqueue = OperationQueue()

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCell.identifier, for: indexPath) as? RecentCell else {
            fatalError("error cell type")
        }
    
        let index = indexPath.row
        let date = self.recent.date(index: index).description
        // Configure the cell
        cell.loadingQueue = self.loadingqueue
        cell.file = self.recent[index]
        cell.date.text = String(date[..<date.finalSubStringIndex(by: ":", leading: true)])
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        //获取选中的item
        guard let item = collectionView.cellForItem(at: indexPath) as? FileCell else {
            fatalError("item no sense")
        }
        
        item.picture.isHidden = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        //获取选中的item
        guard let item = collectionView.cellForItem(at: indexPath) as? FileCell else {
            fatalError("item no sense")
        }
        
        item.picture.isHidden = false
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //获取选中的item
        guard let item = collectionView.cellForItem(at: indexPath) as? FileCell else {
            fatalError("item no sense")
        }
        
        guard let file = item.file else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: file.path) else {
            return
        }
        
        self.openFile(file)
    }
    
    @objc func longPressOnCell(_ longpress: UILongPressGestureRecognizer) {
        guard longpress.state == .began else {
            return
        }
        
        guard let collection = self.collectionView else {
            fatalError("collection view not found")
        }
        
        let point = longpress.location(in: collection)
        
        guard let index = collection.indexPathForItem(at: point) else {
            return
        }
        
        guard let cell = collection.cellForItem(at: index) as? RecentCell else {
            return
        }
        
        self.openFileParent(cell)
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension RecentViewController: RecentDelegate {
    func reload() {
        self.collectionView?.reloadData()
    }
    
    fileprivate func clear() {
        self.recent.removeAll()
    }
    
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(forName: Notification.RHPlayer.ClearCache, object: nil, queue: OperationQueue.main, using: clearCache)
        
        //longpress
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell(_:)))
        OperationQueue.main.addOperation {
            self.collectionView?.addGestureRecognizer(longpress)
        }
    }
    
    fileprivate func clearCache(_ notification: Notification) {
        self.clear()
        self.clearCacheFinish()
    }
    
    fileprivate func clearCacheFinish() {
        NotificationCenter.default.post(Notification(name: Notification.RHPlayer.ClearCacheFinish))
    }
    
    fileprivate func openFile(_ file: File) {
        self.tabBarController?.selectedIndex = LibraryController.tabBarIndex
        NotificationCenter.default.post(Notification(name: Notification.RHPlayer.OpenFile, object: nil, userInfo: ["file" : file]))
    }
    
    fileprivate func openFileParent(_ cell: RecentCell) {
        guard let file = cell.file else {
            fatalError("file not found")
        }
        
        guard FileManager.default.fileExists(atPath: file.path) else {
            return
        }
        
        self.openFile(file.parent)
    }
}

