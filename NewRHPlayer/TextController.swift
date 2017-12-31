//
//  TextController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/3.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class TextController: FileViewController {
    
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBarController?.tabBar.isHidden = true
        // async
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func singleTap(_ tapGesture: UITapGestureRecognizer) {
        if let isHide = navigationController?.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(!isHide, animated: true)
        }
    }
    
    @objc func swipeBack(_ edgePanGesture: UIScreenEdgePanGestureRecognizer) {
        if edgePanGesture.state == .ended {
            tabBarController?.tabBar.isHidden = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        tabBarController?.tabBar.isHidden = false
    }
}

extension TextController {
    fileprivate func load() {
        let queue = OperationQueue()
        queue.name = "text controller loading"
        queue.addOperation {
            // 一定是text
            guard let textSource = self.source as? Text else {
                fatalError("error type of a text")
            }
            guard let text = try? String(contentsOfFile: textSource.path) else {
                return
            }
            // UI update
            OperationQueue.main.addOperation {
                self.navigationItem.title = textSource.name
                self.content.text = text
            }
        }
        // gestures load
        queue.addOperation {
            self.addGestures()
        }
    }
    
    fileprivate func addGestures() {
        //single tap hide
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        tap.numberOfTapsRequired = 1
        OperationQueue.main.addOperation {
            self.content.addGestureRecognizer(tap)
        }
        //edge swipe back
        let swipeback = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipeBack(_:)))
        swipeback.edges = .left
        OperationQueue.main.addOperation {
            self.content.addGestureRecognizer(swipeback)
        }
    }
}
