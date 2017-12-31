//
//  SettingsController.swift
//  NewRHPlayer
//
//  Created by 王宇鑫 on 2017/11/2.
//  Copyright © 2017年 王宇鑫. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    @IBOutlet weak var unzipDeleteSwitch: UISwitch!
    @IBOutlet weak var clearCacheButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    static public let unzipDelete = "unzipDelete"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.addObserver()
        self.load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unzipDeleteSwitchChange(_ sender: UISwitch) {
        guard sender === unzipDeleteSwitch else {
            fatalError("只有unzipDeleteSwitch能调用这个方法")
        }
        
        UserDefaults.standard.set(unzipDeleteSwitch.isOn, forKey: SettingsController.unzipDelete)
    }
    
    @IBAction func clearCache(_ sender: UIButton) {
        guard sender === clearCacheButton else {
            fatalError("此方法只有clearCacheButton可以调用")
        }
        
        self.indicator.startAnimating()
        NotificationCenter.default.post(Notification(name: Notification.RHPlayer.ClearCache))
    }
    
    /*
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
     */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsController {
    fileprivate func load() {
        unzipDeleteSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsController.unzipDelete)
    }
    
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(forName: Notification.RHPlayer.ClearCacheFinish, object: nil, queue: OperationQueue.main, using: clearCacheFinish)
    }
    
    fileprivate func clearCacheFinish(_ notification: Notification) {
        self.clearCacheFinish()
        self.indicator.stopAnimating()
    }
    
    fileprivate func clearCacheFinish() {
        let clearCacheAlert = UIAlertController(title: "success", message: "finish clear cache", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "confirm", style: .cancel, handler: nil)
        
        clearCacheAlert.addAction(confirm)
        self.present(clearCacheAlert, animated: true, completion: nil)
    }
}
