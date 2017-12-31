//
//  PictureController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/7.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class PictureController: FileViewController, UIScrollViewDelegate {
    @IBOutlet weak var pictureSelector: UISlider!
    @IBOutlet weak var pictureListView: UIView!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var indexNow: UILabel!
    @IBOutlet weak var indexMax: UILabel!
    
    var pictureList: PictureList?
    private var gotoView = UIImageView()
    private var nowView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scroll.delegate = self
        // settings
        settings()
        // async
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return picture
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard sender === self.pictureSelector else {
            print("other slider cannot use this function")
            return
        }

        self.goto(index: Int(self.pictureSelector.value))
    }
    
    //被scrollview和picturelistview共用
    @objc func singleTap(_ tapGesture: UITapGestureRecognizer) {
        guard pictureListView.isHidden else {
            pictureListView.isHidden = true
            return
        }
        guard scroll.zoomScale == 1.0 else {
            pictureListView.isHidden = false
            return
        }
        let touch = tapGesture.location(in: self.picture)
        let bounds = self.picture.bounds
        let leftside = CGRect(x: 0, y: 0, width: bounds.width / 3, height: bounds.height)
        let rightside = CGRect(x: bounds.width * 2 / 3, y: 0, width: bounds.width / 3, height: bounds.height)
        if leftside.contains(touch) {
            self.tolast()
        } else if rightside.contains(touch) {
            self.tonext()
        } else {
            pictureListView.isHidden = false
        }
    }
    
    @objc func doubleTap(_ tapGesture: UITapGestureRecognizer) {
        if scroll.zoomScale > scroll.minimumZoomScale {
            scroll.setZoomScale(scroll.minimumZoomScale, animated: true)
        } else {
            scroll.setZoomScale(scroll.zoomScale + 1, animated: true)
        }
    }
    
    @objc func leftSwipe(_ swipeGesture: UISwipeGestureRecognizer) {
        self.tonext()
    }
    
    @objc func rightSwipe(_ swipeGesture: UISwipeGestureRecognizer) {
        self.tolast()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("leave picture")
    }
}

extension PictureController {
    fileprivate func tolast() {
        guard let picturelist = self.pictureList else {
            return
        }
        
        let last = picturelist.index - 1
        self.gotoAnimation(index: last)
        self.goto(index: last)
    }
    
    fileprivate func tonext() {
        guard let picturelist = self.pictureList else {
            return
        }
        
        let next = picturelist.index + 1
        self.gotoAnimation(index: next)
        self.goto(index: next)
    }
    
    fileprivate func gotoAnimation(index: Int) {
        guard let now = self.pictureList?.index else {
            return
        }
        
        guard let success = self.pictureList?.legal(index: index), success else {
            return
        }
        
        self.gotoView.image = self.pictureList?[index].picture
        self.nowView.image = self.pictureList?.now.picture
        let width = self.picture.bounds.width
        let dx = index > now ? width : -width
        self.gotoView.center.x += dx
        self.gotoView.isHidden = false
        self.nowView.isHidden = false
        self.picture.isHidden = true
        UIView.animate(withDuration: 0.33, animations: {
            self.gotoView.center.x -= dx
            self.nowView.center.x -= dx
        }) { success in
            self.gotoView.isHidden = true
            self.nowView.isHidden = true
            self.picture.isHidden = false
            self.nowView.center.x += dx
        }
    }
    
    fileprivate func goto(index: Int) {
        guard let picturelist = self.pictureList else {
            return
        }
        
        guard picturelist.legal(index: index) else {
            return
        }
        
        picturelist.index = index
        
        self.picture.image = picturelist.now.picture
        self.pictureSelector.value = Float(index)
        self.indexNow.text = String(describing: index + 1)
    }
    
    fileprivate func load() {
        let queue = OperationQueue()
        queue.name = "picture controller loading"
        //
        let loadImage = BlockOperation {
            //一定是picture
            guard let pictureSource = self.source as? Picture else {
                fatalError("error type of a picture")
            }
            // UI update
            OperationQueue.main.addOperation {
                self.picture.image = pictureSource.picture
            }
        }
        queue.addOperation(loadImage)
        //
        let loadPictureList = BlockOperation {
            //一定是picture
            guard let pictureSource = self.source as? Picture else {
                fatalError("error type of a picture")
            }
            
            self.pictureList = PictureList(pictureSource.parent)
            OperationQueue.main.addOperation {
                guard let picturelist = self.pictureList else {
                    fatalError("刚刚才设置过picturelist，不可能没有")
                }
                
                self.pictureSelector.maximumValue = Float(picturelist.count - 1)
                self.indexMax.text = String(describing: picturelist.count)
            }
        }
        queue.addOperation(loadPictureList)
        //
        let setPictureStartIndex = BlockOperation {
            //一定是picture
            guard let pictureSource = self.source as? Picture else {
                fatalError("error type of a picture")
            }
            guard let picturelist = self.pictureList else {
                return
            }
            
            self.pictureList?.setIndex(with: pictureSource)
            OperationQueue.main.addOperation {
                self.pictureSelector.value = Float(picturelist.index)
                self.indexNow.text = String(describing: picturelist.index + 1)
            }
        }
        setPictureStartIndex.addDependency(loadImage)
        setPictureStartIndex.addDependency(loadPictureList)
        queue.addOperation(setPictureStartIndex)
        // load gestures
        queue.addOperation {
            self.addGestures()
        }
    }
    
    private func settings() {
        // animation init
        self.scroll.addSubview(self.gotoView)
        self.scroll.addSubview(self.nowView)
        self.gotoView.isHidden = true
        self.nowView.isHidden = true
        self.gotoView.contentMode = self.picture.contentMode
        self.nowView.contentMode = self.picture.contentMode
        self.gotoView.frame = self.picture.frame
        self.nowView.frame = self.picture.frame
    }
    
    private func addGestures() {
        //single tap on scroll view
        let tapOnScroll = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        tapOnScroll.numberOfTapsRequired = 1
        OperationQueue.main.addOperation {
            self.scroll.addGestureRecognizer(tapOnScroll)
        }
        //single tap on picture list view
        let tapOnPictureList = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        tapOnPictureList.numberOfTapsRequired = 1
        OperationQueue.main.addOperation {
            self.pictureListView.addGestureRecognizer(tapOnPictureList)
        }
        //double tap zoom
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        OperationQueue.main.addOperation {
            self.scroll.addGestureRecognizer(doubleTap)
        }
        //require fail
        tapOnScroll.require(toFail: doubleTap)
        //swipe left
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe(_:)))
        leftSwipe.direction = .left
        OperationQueue.main.addOperation {
            self.scroll.addGestureRecognizer(leftSwipe)
        }
        //swipe right
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe(_:)))
        rightSwipe.direction = .right
        OperationQueue.main.addOperation {
            self.scroll.addGestureRecognizer(rightSwipe)
        }
    }
}
