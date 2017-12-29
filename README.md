# SendSandBoxFileSwift

一行代码 沙盒 SandBox ,文件利用Email, AirDrop, WebView，发送到电脑或者邮箱里。比如图片，视频，其他类型文件


```
pod 'SendSandBoxFileSwift'
pod install
```

直接使用
```
let fileListVC =  FileListTableViewController();
self.navigationController?.pushViewController(fileListVC, animated: true);
```

指定特定文件路径和默认邮箱

```
let fileListVC =  FileListTableViewController();
fileListVC.defaultMail = "test1@gmail.com, test2@gmail.com, test3@gmail.com,"
let documentPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first;
fileListVC.directoryStr = documentPath;
self.present(fileListVC, animated: true) {
NSLog("present vc");
};

```

效果图：

![image](./SnapImage/IMG_2389.PNG)
