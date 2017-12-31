//
//  LibraryController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/2.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit
import AVKit

class LibraryController: UICollectionViewController {
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var back: UIButton!
    
    private var library = Directory()
    private var recent = Recent.shared
    
    public static let tabBarIndex = 0
    
    fileprivate var isloading = false {
        didSet {
            if self.isloading {
                self.loading.startAnimating()
                self.lock()
            } else {
                self.loading.stopAnimating()
                self.unlock(condition: !self.animation.isAnimating)
            }
        }
    }
    
    fileprivate let loadingqueue = OperationQueue()
    
    fileprivate var open = Open.initiation
    
    fileprivate var contentoffset = [CGPoint]()
    
    fileprivate var swipeBackEnabled = true

    fileprivate lazy var animation = {
        return OpenDirectoryAnimation(libController: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Do any additional setup after loading the view.
        //
        OperationQueue.main.addOperation {
            self.openDirectory(self.library)
        }
        // gestures
        loadingqueue.addOperation {
            self.addGestures()
            self.addObserver()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        guard let file = sender as? File else {
            return
        }

        file.prepare(for: segue.destination)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return library.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= self.library.count {
            let nonecell = collectionView.dequeueReusableCell(withReuseIdentifier: File.type.none.form, for: indexPath)
            nonecell.isHidden = true
            return nonecell
        }
        
        let file = library[indexPath.row]
        
        let form = file.type.form
        let origin = collectionView.dequeueReusableCell(withReuseIdentifier: form, for: indexPath)
        //不可能不继承自FileCell
        guard let cell = origin as? FileCell else {
            fatalError("cell没有继承自FileCell")
        }

        // Configure the cell
        cell.loadingQueue = loadingqueue
        cell.file = file

        return cell
    }

    //item select
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //获取选中的item
        guard let item = collectionView.cellForItem(at: indexPath) as? FileCell else {
            fatalError("item no sense")
        }
        
        self.open(with: item)
    }
    //
    @IBAction func backToLibrary(sender: UIStoryboardSegue) {
        print("back to library")
    }
    
    @IBAction func popBack(_ sender: UIButton) {
        popBack()
    }
    
    @objc func swipeBack(_ edgePanGesture: UIScreenEdgePanGestureRecognizer) {
        if edgePanGesture.state == .ended {
            if self.swipeBackEnabled {
                popBack()
            }
        }
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
        
        guard let cell = collection.cellForItem(at: index) as? FileCell else {
            return
        }
        openDetail(cell)
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
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("perform")
    }
    */
}

extension LibraryController {
    fileprivate class OpenDirectoryAnimation {
        init(libController: LibraryController) {
            self.libController = libController
        }
        
        private let libController: LibraryController
        private var animationImageViews = [UIImageView]()
        private var animationImageRect = CGRect()
        private var animating = false {
            didSet {
                if self.animating {
                    self.libController.lock()
                } else {
                    self.libController.unlock(condition: !self.libController.isloading)
                }
            }
        }
        
        var isAnimating: Bool {
            return self.animating
        }
        
        func pop() -> UIImageView? {
            return self.animationImageViews.popLast()
        }
        
        func pushAnimation(item: FileCell, offset: CGPoint) {
            self.animating = true
            self.animationImageViews.append(UIImageView(image: item.picture.image))
            guard let aiv = self.animationImageViews.last else {
                fatalError("animation image view init error")
            }
            aiv.center = CGPoint(x: item.center.x - offset.x - (item.bounds.width / 2) + item.picture.center.x, y: item.center.y - offset.y - (item.bounds.height / 2) + item.picture.center.y)
            animationImageRect = aiv.bounds
            aiv.contentMode = .scaleAspectFit
            libController.view.addSubview(aiv)
            UIView.animate(withDuration: 0.33, animations: {
                aiv.bounds = self.libController.view.bounds
            }) {
                success in
                aiv.isHidden = true
                self.animating = false
            }
        }
        
        func popAnimation() {
            guard let aiv = self.animationImageViews.last else {
                print("animation image views not found")
                return
            }
            self.animating = true
            aiv.isHidden = false
            UIView.animate(withDuration: 0.33, animations: {
                aiv.bounds = self.animationImageRect
            }) {
                success in
                self.pop()?.removeFromSuperview()
                self.animating = false
            }
        }
    }
    
    fileprivate enum Open {
        case into
        case back
        case initiation
        case detail
        case none
    }
    
    fileprivate func open(with item: FileCell) {
        guard let file = item.file else {
            fatalError("file not found")
        }
        
        switch file.type {
        case .directory:
            openDirectory(with: item)
        case .zip:
            self.recent.append(file: file)
            openZip(with: item)
        case .picture, .video, .text:
            self.recent.append(file: file)
            openFileSegue(with: item)
        default:
            openUnknownFile(with: item)
        }
    }
    
    fileprivate func openDirectory(with item: FileCell) {
        guard let offset = collectionView?.contentOffset else {
            fatalError("collection view content offset not found")
        }
        self.animation.pushAnimation(item: item, offset: offset)
        self.open = .into
        openDirectory(item.file as? Directory)
    }
    
    fileprivate func openZip(with item: FileCell) {
        guard let offset = collectionView?.contentOffset else {
            fatalError("collection view content offset not found")
        }
        
        self.animation.pushAnimation(item: item, offset: offset)
        openZip(item.file as? Zip)
    }
    
    fileprivate func passwordInputView(_ zip: Zip) {
        let passwordAlert = UIAlertController(title: "need password", message: "please input zip file password", preferredStyle: .alert)
        
        passwordAlert.addTextField { passwordTextField in
            passwordTextField.placeholder = "password"
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "confirm", style: .default) { action in
            guard let password = passwordAlert.textFields?.first?.text else {
                return
            }
            
            zip.password = password
            self.openZip(zip)
        }
        
        passwordAlert.addAction(cancel)
        passwordAlert.addAction(confirm)
        self.present(passwordAlert, animated: true, completion: nil)
    }
    
    fileprivate func passwordGetter(_ zip: Zip) {
        self.passwordInputView(zip)
    }
    
    fileprivate func openZip(_ at: Zip?) {
        guard let zip = at else {
            fatalError("file doesn't exist")
        }
        if !self.isloading {
            self.isloading = true
        }
        let block = BlockOperation {
            let state = zip.unzip()
            guard state != Zip.State.fail && state != Zip.State.password else {
                let _ = self.animation.pop()
                OperationQueue.main.addOperation {
                    self.isloading = false
                }
                if state == Zip.State.password {
                    OperationQueue.main.addOperation {
                        self.passwordGetter(zip)
                    }
                }
                return
            }
            
            guard let dstdir = zip.dstdir else {
                fatalError("unzip error")
            }
            
            OperationQueue.main.addOperation {
                self.open = Open.into
                self.openDirectory(dstdir)
            }
        }
        loadingqueue.addOperation(block)
    }
    
    fileprivate func openDirectory(_ directory: Directory?) {
        //应该是directory类型
        guard let dir = directory else {
            fatalError("when open an directory: error type of directory")
        }
        guard open != .none else {
            fatalError("none open state")
        }
        //save offset
        if open == .into {
            guard let offset = self.collectionView?.contentOffset else {
                fatalError("offset not found")
            }
            self.contentoffset.append(offset)
        }
        //set
        self.library = dir
        //load asynchronized
        if !self.isloading {
            self.isloading = true
        }
        let operations = BlockOperation {
            self.library.load()
            OperationQueue.main.addOperation {
                if self.isloading {
                    self.isloading = false
                }
            }
        }
        loadingqueue.addOperation(operations)
        
        if library.isHome {
            back.isHidden = true
        } else {
            back.isHidden = false
        }
        
        navigationItem.title = library.name
    }
    
    fileprivate func openFileSegue(with filecell: FileCell) {
        guard let file = filecell.file else {
            fatalError("cell should have a file")
        }
        
        performSegue(withIdentifier: file.type.controllerID, sender: file)
    }
    
    fileprivate func openUnknownFile(with filecell: FileCell) {
        //文件应该存在
        guard let f = filecell.file else {
            fatalError("file should exist")
        }
        
        print(f.name)
    }
    
    fileprivate func popBack() {
        guard !library.isHome else {
            return
        }
        self.animation.popAnimation()
        self.open = .back
        openDirectory(library.parent)
    }
    
    //lock
    fileprivate func lock() {
        self.collectionView?.allowsSelection = false
        self.back.isEnabled = false
        self.swipeBackEnabled = false
    }
    
    fileprivate func unlock(condition: Bool) {
        if condition {
            self.collectionView?.allowsSelection = true
            self.back.isEnabled = true
            self.swipeBackEnabled = true
            self.collectionView?.reloadData()
            //reset offset
            if self.open == Open.back {
                guard let offset = self.contentoffset.popLast() else {
                    return
                }
                self.collectionView?.contentOffset = offset
            }
            self.open = .none
        }
    }
    
    fileprivate func openDetail(_ filecell: FileCell) {
        guard let file = filecell.file else {
            fatalError("cell should have a file")
        }
        
        openDetail(file)
    }
    
    fileprivate func openDetail(_ file: File) {
        performSegue(withIdentifier: "detail", sender: file)
    }
    
    fileprivate func addGestures() {
        //swipeback
        let swipeback = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipeBack(_:)))
        swipeback.edges = .left
        //longpress
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell(_:)))
        OperationQueue.main.addOperation {
            self.collectionView?.addGestureRecognizer(swipeback)
            self.collectionView?.addGestureRecognizer(longpress)
        }
    }
    
    fileprivate func openFile(_ notification: Notification) {
        guard let file = notification.userInfo?["file"] as? File else {
            fatalError("error notification without file")
        }
        
        switch file.type {
        case .directory:
            open = .into
            openDirectory(file as? Directory)
        case .zip:
            self.recent.append(file: file)
            openZip(file as? Zip)
        case .none:
            break
        default:
            self.recent.append(file: file)
            performSegue(withIdentifier: file.type.controllerID, sender: file)
        }
    }
    
    fileprivate func deleteFile(_ notification: Notification) {
        guard let file = notification.userInfo?["file"] as? File else {
            fatalError("error notification without file")
        }
        
        self.lock()
        
        loadingqueue.addOperation {
            let success = file.parent.delete(file: file)
            
            if !success {
                print("delete failed")
            }
            
            OperationQueue.main.addOperation {
                self.unlock(condition: true)
            }
        }
    }
    
    fileprivate func renameFile(_ notification: Notification) {
        guard let file = notification.userInfo?["file"] as? File,
            let name = notification.userInfo?["name"] as? String else {
                fatalError("error notification without file")
        }
        
        self.lock()
        
        loadingqueue.addOperation {
            let success = file.parent.rename(file: file, name: name)
            
            OperationQueue.main.addOperation {
                self.unlock(condition: true)
            }
            
            if !success {
                print("rename failed")
            }
        }
    }
    
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(forName: Notification.RHPlayer.OpenFile, object: nil, queue: OperationQueue.main, using: openFile)
        NotificationCenter.default.addObserver(forName: Notification.RHPlayer.DeleteFile, object: nil, queue: OperationQueue.main, using: deleteFile)
        NotificationCenter.default.addObserver(forName: Notification.RHPlayer.RenameFile, object: nil, queue: OperationQueue.main, using: renameFile)
    }
}
