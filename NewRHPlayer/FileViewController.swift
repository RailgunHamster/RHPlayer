//
//  FileViewController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/11.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

/*
TODO:
    利用 CoreData（储存Data）
    Archives and Serializations（储存Data）
    DispatchQueue（异步加载资源）
    优化程序的结构/行为
*/

import UIKit

class FileViewController: UIViewController, FileDelegate {

    var source: File?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
