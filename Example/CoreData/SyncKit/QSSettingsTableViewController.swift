//
//  QSSettingsTableViewController.swift
//  SyncKitCoreDataExample
//
//  Created by Jérôme Haegeli on 25.07.18.
//  Copyright © 2018 Manuel. All rights reserved.
//

import SyncKit
import UIKit

class QSSettingsTableViewController: UITableViewController {
    var privateSynchronizer: QSCloudKitSynchronizer?
    var sharedSynchronizer: QSCloudKitSynchronizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            privateSynchronizer?.eraseRemoteAndLocalData(for: (privateSynchronizer?.modelAdapters().first)!, withCompletion: { error in
                DispatchQueue.main.async(execute: {
                    var message: String
                    if error != nil {
                        message = "There was an error erasing data"
                    } else {
                        message = "Erased private data"
                    }
                    let alertController = UIAlertController(title: "Erase", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true)
                })
            })
        }
        
        if indexPath.row == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            if UserDefaults.standard.bool(forKey: "autoSyncEnabled") {
                cell?.textLabel?.text = "Auto Sync disabled (tap to toggle)"
                cell?.setSelected(false, animated: true)
                UserDefaults.standard.set(false, forKey: "autoSyncEnabled")
            } else {
                let appDelegate = UIApplication.shared.delegate as! QSAppDelegate
                appDelegate.checkPushNotification { (isEnabled) in
                    if !isEnabled {
                        let cell = tableView.cellForRow(at: indexPath)
                        let alert = UIAlertController(title: "Warning", message: "Notifications need to be activated to perform auto sync in background. Do you want to active them now ?", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            if !appDelegate.requestNotificationAuthorization() {
                                let alert = UIAlertController(title: "Error", message: "Error occured", preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "Camcel", style: .default, handler: nil)
                                alert.addAction(cancel)
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                DispatchQueue.main.async {
                                    cell?.textLabel?.text = "Auto Sync enabled (tap to toggle)"
                                    cell?.setSelected(false, animated: true)
                                    UserDefaults.standard.set(true, forKey: "autoSyncEnabled")
                                    CoreDataStack.shared.synchronizer?.synchronize(completion: nil)
                                    CoreDataStack.shared.sharedSynchronizer?.synchronize(completion: nil)
                                }
                                
                            }
                        })
                        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        alert.addAction(action)
                        alert.addAction(cancel)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        DispatchQueue.main.async {
                            cell?.textLabel?.text = "Auto Sync enabled (tap to toggle)"
                            cell?.setSelected(false, animated: true)
                            UserDefaults.standard.set(true, forKey: "autoSyncEnabled")
                            CoreDataStack.shared.synchronizer?.synchronize(completion: nil)
                            CoreDataStack.shared.sharedSynchronizer?.synchronize(completion: nil)
                        }
                    }
                    print("check notification finished")
                }
            }
        }
        
        if indexPath.row == 2 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.textLabel?.text = "Syncing..."
            cell?.textLabel?.textColor = .gray
            cell?.setSelected(false, animated: true)
            CoreDataStack.shared.synchronizer?.synchronize(completion: { (error) in
                CoreDataStack.shared.sharedSynchronizer?.synchronize(completion: { (error) in
                    cell?.textLabel?.text = "Sync manually"
                    cell?.textLabel?.textColor = .black
                })
            })
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "eraseCell")
            cell.textLabel?.text = "Erase all"
        }
        
        if indexPath.row == 1 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "autoSyncCell")
            if UserDefaults.standard.bool(forKey: "autoSyncEnabled") {
                cell.textLabel?.text = "Auto Sync enabled (tap to toggle)"
            } else {
                cell.textLabel?.text = "Auto Sync disabled (tap to toggle)"
            }
        }

        if indexPath.row == 1 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "autoSyncCell")
            if UserDefaults.standard.bool(forKey: "autoSyncEnabled") {
                cell.textLabel?.text = "Auto Sync enabled (tap to toggle)"
            } else {
                cell.textLabel?.text = "Auto Sync disabled (tap to toggle)"
            }
        }
        
        if indexPath.row == 2 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "syncCell")
            cell.textLabel?.text = "Sync manually"
        }
        
        return cell
    }
    
}

