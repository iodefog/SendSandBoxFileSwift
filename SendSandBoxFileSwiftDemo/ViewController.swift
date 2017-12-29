//
//  ViewController.swift
//  SendSandBoxFileSwiftDemo
//
//  Created by LHL on 2017/12/20.
//  Copyright © 2017年 HL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushListVC(_ sender: Any) {
       let fileListVC =  FileListTableViewController();
      self.navigationController?.pushViewController(fileListVC, animated: true);
    }
    
    @IBAction func presentListVC(_ sender: Any) {
        let fileListVC =  FileListTableViewController();
        fileListVC.defaultMail = "test1@gmail.com, test2@gmail.com, test3@gmail.com,"
        let documentPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first;
        fileListVC.directoryStr = documentPath;
        self.present(fileListVC, animated: true) {
            NSLog("present vc");
        };
    }
}

