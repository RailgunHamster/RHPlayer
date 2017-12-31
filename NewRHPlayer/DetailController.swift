//
//  DetailController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/12/8.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class DetailController: FileViewController {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var filetitle: UITextView!
    
    fileprivate var saveFileTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.filetitle.delegate = self
        load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard saveFileTitle != filetitle.text else {
            return
        }
        
        guard let file = self.source else {
            fatalError("source not found")
        }
        
        NotificationCenter.default.post(Notification(name: Notification.RHPlayer.RenameFile, object: nil, userInfo: ["file" : file, "name" : filetitle.text]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func touchUpInsidePicture(_ tapGesture: UITapGestureRecognizer) {
        guard tapGesture.state == .ended else {
            return
        }
        
        openFile()
    }
    
    @IBAction func deleteFile(_ sender: UIButton) {
        guard sender === self.delete else {
            print("only the delete button can use this function")
            return
        }
        
        guard let file = self.source else {
            fatalError("source not found")
        }
        
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(Notification(name: Notification.RHPlayer.DeleteFile, object: nil, userInfo: ["file" : file]))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */
}

extension DetailController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            self.filetitle.resignFirstResponder()
            return false
        }
        return true
    }
}

extension DetailController {
    fileprivate func load() {
        guard let file = source else {
            fatalError("file not found")
        }
        
        let loading = OperationQueue()
        loading.name = "loading queue"
        
        // load image asynchronized or straightly
        if file.isPictureLoadingNeedsTime {
            loading.addOperation {
                let image = file.picture
                OperationQueue.main.addOperation {
                    self.picture.image = image
                }
            }
        } else {
            self.picture.image = file.picture
        }
        
        //add observer
        let touch = UITapGestureRecognizer(target: self, action: #selector(touchUpInsidePicture(_:)))
        self.picture.addGestureRecognizer(touch)
        
        filetitle.text = file.fullname
        saveFileTitle = filetitle.text
    }
    
    fileprivate func openFile() {
        guard let file = self.source else {
            fatalError("source not found")
        }
        
        switch file.type {
        case .directory, .zip:
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(Notification(name: Notification.RHPlayer.OpenFile, object: nil, userInfo: ["file" : file]))
        case .none:
            return
        default:
            self.navigationController?.popViewController(animated: false)
            NotificationCenter.default.post(Notification(name: Notification.RHPlayer.OpenFile, object: nil, userInfo: ["file" : file]))
        }
    }
}
