//
//  FileListTableViewController.swift
//  SendSandBoxFileSwiftDemo
//
//  Created by LHL on 2017/12/20.
//  Copyright © 2017年 HL. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
/**   遍历沙盒目录下文件，如果是非文件夹。则发送邮件
 *    使用方法 preset or push
 */

let HLNavigationBarHeight:CGFloat = 64;


class FileListTableViewController: UITableViewController,MFMailComposeViewControllerDelegate {

    //  文件目录起始路径，默认为root
    var directoryStr:String? = nil;
    
    //  默认邮箱地址，或者字符串。例如 xxx@mail.com, 多个请用"AAA@gmail.com,BBB@gmail.com,CCC@gmail.com"
    var defaultMail:String?  = nil;

    
    var documentController:UIDocumentInteractionController? = nil;
    var fileList:NSMutableArray? = nil;
    var headerView:UIView? = nil;
    var ttNavigationItem:UINavigationItem? = nil;

    // MARK:-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white;
        
        if (directoryStr == nil) {
            directoryStr = NSHomeDirectory() as String;
        }
        
        let array:NSArray? = try? FileManager.default.contentsOfDirectory(atPath: directoryStr!) as NSArray ;
        if array != nil {
            let enumerator:NSEnumerator? = array?.reverseObjectEnumerator();
            self.fileList = NSMutableArray.init(array: (enumerator!.allObjects), copyItems: true);
        }

        // 非NavigationBar 创建一个
        var navigationItem:UINavigationItem? = self.navigationItem;
        if (self.navigationController == nil) {
            navigationItem = UINavigationItem();
            let navigationBar:UINavigationBar = UINavigationBar.init(frame: CGRect.init(x: 0, y: 0, width: Int(CGFloat(self.view.frame.size.width)), height: Int(HLNavigationBarHeight)))
            navigationBar.pushItem(navigationItem!, animated: false);
            headerView=navigationBar;
            self.view.addSubview(navigationBar);
        }
        
        if(self.title == nil){
            navigationItem?.title = self.title;
        }
        else {
            navigationItem?.title="/";
        }
    
        if (self.navigationController == nil) {
            let backBarItem:UIBarButtonItem? = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(FileListTableViewController.back));
            navigationItem?.leftBarButtonItem=backBarItem;
        }
        
        let remveBarItem:UIBarButtonItem? = UIBarButtonItem.init(title: "Clear", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FileListTableViewController.removeAllFiles));
        navigationItem?.rightBarButtonItem = remveBarItem;
        
        self.ttNavigationItem = navigationItem;
    }

    // MARK: - 返回前一页
    @objc func back() -> Void {
        if (self.navigationController == nil) {
            self.dismiss(animated: true, completion: nil);
        }
        else {
            self.navigationController?.popViewController(animated: true);
        }
    }
    
    // MARK: - 删除所有文件
    @objc func removeAllFiles() {
        var filePath = self.directoryStr;
        if filePath == nil {
            filePath = NSHomeDirectory();
        }
        
        let fileList:Array = try! FileManager.default.contentsOfDirectory(atPath: filePath!)
        for fileName in fileList {
            self.removeOneFileForFileName(fileName: fileName);
        }
        self.fileList?.removeAllObjects();
        self.tableView.reloadData();
    }
    
    
    // MARK: - 删除某一个文件
    @objc func removeOneFileForFileName(fileName:String) -> Void {
        let filePath = String.init(format: "%@/%@", self.directoryStr!, fileName);
        do{
           try FileManager.default.removeItem(atPath: filePath);
        }
        catch let error as NSError{
            if #available(iOS 8.0, *) {
                let alertController  =   UIAlertController.init(title: nil, message: String.init(format: "删除文件失败\n %@", error as CVarArg), preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction);
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                // Fallback on earlier versions
            };
            
        }
        
    }
    
    // MARK: - 获取沙盒路径
    @objc func getSendBoxPath(path:String?) -> String? {
        
        var tempDirectoryStr:String? = nil;
        if(self.directoryStr == nil){
            tempDirectoryStr = NSHomeDirectory() ;
            self.directoryStr = tempDirectoryStr;
        }
        
        if (path != nil) {
            tempDirectoryStr = String.init(format: "%@/%@", self.directoryStr!, path!);
        }
        
        return tempDirectoryStr;
    }
    
    // MARK: - 发送邮件
    @objc func sendMail(fileName:String){
        if (MFMailComposeViewController.canSendMail() == false) {
            launchMailAppOnDevice(fileName: fileName);
            return;
        }
        
        let mailPicker:MFMailComposeViewController = MFMailComposeViewController.init();
        mailPicker.mailComposeDelegate = self;
        // 设置主题
        mailPicker.setSubject("Sandbox目录文件")
        // 添加发送者
        let mails = self.defaultMail?.components(separatedBy: ",");
        mailPicker.setToRecipients(mails)
        let path = String.init(format: "%@/%@", self.directoryStr!, fileName);
        let data = NSData.init(contentsOfFile: path);
        mailPicker.addAttachmentData(data! as Data, mimeType: "text/plain", fileName: fileName);
        self.present(mailPicker, animated: true, completion: nil);
    }
    
    // MARK: - 发送成功或者失败，取消等回调
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - 低版本使用拉起safari发送
    @objc func launchMailAppOnDevice(fileName:String) {
        let path:String? = String.init(format: "%@/%@", self.directoryStr!, fileName);
        if self.defaultMail == nil {
            self.defaultMail = "";
        }
        
        let urlString:String? = String.init(format:"mailto:%@?subject=%@&body=%@",
            self.defaultMail!,
            "Sandbox目录文件",
            try! String.init(contentsOfFile: path!, encoding: String.Encoding.utf8));
        let newString:String? = urlString?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed);
        
        let url:NSURL? = NSURL.init(string: newString!);
        UIApplication.shared.openURL(url! as URL);
    }
    
    @objc override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.fileList?.count == 0){
            self.ttNavigationItem?.rightBarButtonItem = nil;
        }
        return self.fileList!.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        do {
            return self.headerView;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.navigationController == nil) {
            return HLNavigationBarHeight;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "FileTableViewCell")
        }
        cell?.textLabel?.numberOfLines = 3;
        cell?.textLabel?.text = self.fileList?[indexPath.row] as? String;
    
        var isDirectory: ObjCBool = ObjCBool(false)
        FileManager.default.fileExists(atPath: self.getSendBoxPath(path: cell?.textLabel?.text)!, isDirectory: &isDirectory)
        if (isDirectory.boolValue) {
            DispatchQueue.main.async {
                let filePath:String = self.getSendBoxPath(path: cell?.textLabel?.text)!;
                // 计算文件大小
                let str : String = FileListTableViewController.folderSizeAtPath(folderPath: filePath)!;
                cell?.detailTextLabel?.text = str;
            }
        }
        else {
            DispatchQueue.main.async {
                let filePath:String = self.getSendBoxPath(path: cell?.textLabel?.text)!;
                let fileSize:CLongLong = FileListTableViewController.fileSizeAtPath(filePath: filePath);
                // 计算文件大小
                let str : String = FileListTableViewController.humanReadableStringFromBytes(byteCount: fileSize);
                cell?.detailTextLabel?.text = str;
            }
        }
        return cell!;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filePath:String = self.getSendBoxPath(path: self.fileList![indexPath.row] as? String)!;
        var isDirectory: ObjCBool = ObjCBool(false)
        FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
        if (isDirectory.boolValue) {
            let fileListVC:FileListTableViewController = FileListTableViewController.init();
            fileListVC.directoryStr = filePath;
            fileListVC.title = String.init(format: "/%@", (filePath as NSString).lastPathComponent);
            if(self.navigationController != nil){
                self.navigationController!.pushViewController(fileListVC, animated: true);
            }
            else {
                self.present(fileListVC, animated: true, completion: nil);
            }
        }
        else {
            self.operationFileName(fileName: self.fileList![indexPath.row] as! String);
        }
    }
    
    
    // MARK: - Sheet 弹框
    func operationFileName(fileName:String) -> Void {
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController.init(title: "文件处理", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let mailAction = UIAlertAction.init(title: "邮件发送", style: UIAlertActionStyle.default) { (void) in
                self.sendMail(fileName: fileName);
            }
            let airDropAction = UIAlertAction.init(title: "AirDrop发送", style: UIAlertActionStyle.default, handler: { (void) in
                self.showDocumentFileName(fileName: fileName);
            });
            let readAction = UIAlertAction.init(title: "预览", style: UIAlertActionStyle.default, handler: { (void) in
                self.readLogsFileName(fileName: fileName);
            });
            let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: { (void) in
            
            });
            alertController .addAction(mailAction);
            alertController .addAction(airDropAction);
            alertController .addAction(readAction);
            alertController .addAction(cancelAction);
            self.present(alertController, animated: true, completion: nil);
            
            
        } else {
            // Fallback on earlier versions
        };
    }
    
    // MARK: - 显示AirDrop相关层
    func showDocumentFileName(fileName:String) -> Void {
        let path = String.init(format: "%@/%@", self.directoryStr!,fileName);
        if self.documentController == nil {
            self.documentController = UIDocumentInteractionController.init(url: NSURL.fileURL(withPath: path));
        }
        self.documentController?.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true);
    }
    
     // MARK: - 直接读 文件
    @objc func readLogsFileName(fileName:String) -> Void {
        let path = String.init(format: "%@/%@", self.directoryStr!,fileName);
        let webVC = LogsReadWebViewController();
        webVC.url = path;
        if self.navigationController == nil {
            self.present(webVC, animated: true, completion: nil);
        }
        else {
            self.navigationController!.pushViewController(webVC, animated: true);
        }
    }
    

    // MARK: - 获取文件大小
  class  func folderSizeAtPath(folderPath:String) -> String? {
        let manager = FileManager.default;
    let existes:Bool = manager.fileExists(atPath: folderPath);
    
        if(!Bool(existes))
        {
            return "";
        }
        
        let array:NSArray =  manager.subpaths(atPath: folderPath)! as NSArray
        let childFilesEnumerator:NSEnumerator = array.objectEnumerator()
        var fileName:String? = childFilesEnumerator.nextObject() as? String;
        var folderSize:CLongLong = 0;
        while (fileName != nil) {
            let filePath = String.init(format: "%@/%@", folderPath, fileName!);
            let fileAbsolutePath:String = filePath as String!;
            folderSize += FileListTableViewController.fileSizeAtPath(filePath:fileAbsolutePath);
            fileName = childFilesEnumerator.nextObject() as? String;
        }
        return FileListTableViewController.humanReadableStringFromBytes(byteCount:folderSize);
    }
    
    class func fileSizeAtPath(filePath:String) -> CLongLong {
        let exists:Bool = FileManager.default.fileExists(atPath: filePath);
        var fileSize:CLongLong = 0;
        if Bool(exists) {
            do {
                //return [FileAttributeKey : Any]
                let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                fileSize = CLongLong(attr[FileAttributeKey.size] as! UInt64)
                
                //if you convert to NSDictionary, you can get file size old way as well.
                let dict = attr as NSDictionary
                fileSize = CLongLong(dict.fileSize())
            } catch {
                print("Error: \(error)")
            }
        }
        return fileSize;
    }
    
    // MARK: - 转换不同量级
    class func humanReadableStringFromBytes(byteCount:CLongLong) -> String {
        var numberOfBytes:Float = Float(byteCount);
        var multiplyFactor:Int = 0;
        let tokens = ["bytes","KB","MB","GB","TB","PB","EB","ZB","YB"];
        
        while numberOfBytes > 1024 {
            numberOfBytes /= 1024;
            multiplyFactor = multiplyFactor+1;
        }
        return String.init(format: "%4.2f %@", numberOfBytes, tokens[multiplyFactor]);
    }
    
    
}
