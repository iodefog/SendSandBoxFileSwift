//
//  LogsReadWebViewController.swift
//  SendSandBoxFileSwiftDemo
//
//  Created by LHL on 2017/12/27.
//  Copyright © 2017年 HL. All rights reserved.
//

import UIKit

class LogsReadWebViewController: UIViewController, UIWebViewDelegate {

    var url:String?;
    var webView:UIWebView?;

    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationBar:UINavigationBar?;
        var navigationItem:UINavigationItem?;
        self.view.backgroundColor = UIColor.white;
        if self.navigationController == nil {
            navigationBar = UINavigationBar.init(frame: CGRect.init(x: 0, y: 20, width:Int(self.view.bounds.width), height: 64));
            navigationItem = UINavigationItem.init(title: "预览");
            navigationItem?.leftBarButtonItem = UIBarButtonItem.init(title: "Back", style: UIBarButtonItemStyle.done, target: self, action: #selector(LogsReadWebViewController.back));
            navigationBar?.pushItem(navigationItem!, animated: true);
            self.view.addSubview(navigationBar!);
        }
        else {
            navigationBar = self.navigationController?.navigationBar;
            navigationItem = self.navigationItem;
            navigationItem?.title = "预览";
        }

        if self.url != nil {
            self.webView = UIWebView.init(frame: CGRect.init(x: 0, y: (navigationBar?.bounds.height)!, width: self.view.bounds.width, height: self.view.bounds.height-(navigationBar?.bounds.height)!));
            self.webView!.delegate = self;
            // 只对link识别
            self.webView!.dataDetectorTypes = UIDataDetectorTypes.link;
            self.view.addSubview(self.webView!);
            self .resetData();
//            self.webView?.scalesPageToFit = true;
        }
        self.createWebViewControl(navigationItem: navigationItem!);
    }
    
    // MARK: - 返回
    @objc func back() {
        if(self.navigationController == nil){
            self.dismiss(animated: true, completion: nil);
        }
        else {
            self.navigationController?.popViewController(animated: true);
        }
    }
    
    // MARK: - 加载数据
    func resetData() {
        var htmlstr = try? String.init(contentsOfFile: self.url!, encoding: String.Encoding.utf8);
       htmlstr = htmlstr?.replacingOccurrences(of: "\n", with: "<br/>");
        if(htmlstr != nil){
            // 自动换行
            let newHtml = String.init(format: "<head><style>img{max-width:320px !important;}</style></head><body width=320px style=\"word-wrap:word-wrap; font-family:Arial\">%@</body>", htmlstr!);
            self.webView?.loadHTMLString(newHtml, baseURL: NSURL.fileURL(withPath: self.url!));
        }
        else {
            self.webView?.loadRequest(NSURLRequest.init(url: NSURL.fileURL(withPath: self.url!)) as URLRequest);
        }
    }

    // MARK: - 创建一个回撤和一个reload按钮
    func createWebViewControl(navigationItem:UINavigationItem) -> Void {
        let refreshItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(self.refreshClicked(barItem:)));
        let rewindItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.rewind, target: self, action: #selector(self.rewindClicked(barItem:)));
        navigationItem.rightBarButtonItems = [refreshItem,rewindItem];
    }
    
    @objc func refreshClicked(barItem:UIBarButtonItem) -> Void {
        self.webView?.stopLoading();
        self.webView?.reload();
    }
    
    @objc func rewindClicked(barItem:UIBarButtonItem) -> Void {
        self.webView?.stopLoading();
        self.resetData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}
