//
//  ViewController.swift
//  BackgroundDownloadSwift3
//
//  Created by piyush sinroja on 17/04/17.
//  Copyright © 2017 Piyush. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import QuickLook

class ViewController: UIViewController {
    
    @IBOutlet weak var tblDetails: UITableView! // TableView
    
    var arrayData = [VideoDetail]() // Main Array
    
    var activeDownloads = [String: Download]()
    
    var qlControllerobj : QLPreviewController! = nil
    
    var dataTask: URLSessionDataTask?

    var arrayURLs = [URL]() //arrayURLs
    
    var dicForDocumentIndex = [Int:Int]()
    
    //DownloadsSession
    lazy var downloadsSession: Foundation.URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.BackgroundDownloadSwift3.BackgroundSession")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
       callGETWebservice()
       tblDetails.estimatedRowHeight = 65
        tblDetails.rowHeight = UITableView.automaticDimension;
        tblDetails.separatorInset = .zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:-  GET Webservice
    func callGETWebservice() {
        //RequestForGet Method
        
        // for testing
        arrayData.append(VideoDetail(email: "xyz@gmail.com", image: "https://file-examples.com/wp-content/uploads/2017/10/file-example_PDF_1MB.pdf", lat: nil, long: nil, username: "PiyushSinroja"))
        tblDetails.reloadData()
        /*
        let checkInternet = Constant.reachabilityCheck()
        if checkInternet == true {
            // Constant.showLoadingHUD(ViewController: self)
            view.showLoadingHUDWithText(text: "Loading")
            let url : String = "http://192.168.1.50/zap/backend/web/index.php/webservice/clientdata"
            let webServiceobj = PowerWebservice()
            webServiceobj.delegate = self
            webServiceobj.requestGet_service(strUrl: url, apiIdentifier: "GETWebservice")
        }
        else {
            Constant.InternetConnection(ViewController: self)
        }*/
    }

    //MARK:- Button Next
    @IBAction func btnNext(_ sender: UIBarButtonItem) {
        let docVc : DocumentViewController = self.storyboard?.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        self.navigationController?.pushViewController(docVc, animated: true)
    }

    //MARK:- Cell Button Actions
    @objc func btnDownloadAction(sender: UIButton) {
        if let imgSender = sender.currentBackgroundImage {
            let dataSender = imgSender.pngData()
            let dataEyeButton = #imageLiteral(resourceName: "eye").pngData()
            let dataPlayButton = #imageLiteral(resourceName: "play").pngData()
            let dataDownloadButton = #imageLiteral(resourceName: "iconNew").pngData()
            
            if dataSender == dataDownloadButton {
                let videoDetail = arrayData[sender.tag]
                startDownload(videoDetail)
                tblDetails.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
            }
            else if dataSender == dataEyeButton {
                documentWatch(sender: sender)
            }
            else if dataSender == dataPlayButton {
                videoPlay(sender: sender)
            }
        }
    }
    
    @objc func btnPauseResumeAction(sender: UIButton) {
        let videoDetail = arrayData[sender.tag]
        if(sender.titleLabel!.text == "Pause") {
            pauseDownload(videoDetail)
        } else {
            resumeDownload(videoDetail)
        }
        tblDetails.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
    
    @objc func btnCancelDownloadAction(sender: UIButton) {
        let videoDetail = arrayData[sender.tag]
        cancelDownload(videoDetail)
        tblDetails.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
    
    // Called when the Download button for a VideoDetail is tapped
    func startDownload(_ videoDetail: VideoDetail) {
        if let urlString = videoDetail.image, let url =  URL(string: urlString) {
            // 1
            let download = Download(url: urlString)
            // 2
            download.downloadTask = downloadsSession.downloadTask(with: url)
            // 3
            download.downloadTask!.resume()
            // 4
            download.isDownloading = true
            // 5
            activeDownloads[download.url] = download
        }
    }
    
    // Called when the Pause button for a VideoDetail is tapped
    func pauseDownload(_ videoDetail: VideoDetail) {
        if let urlString = videoDetail.image,
            let download = activeDownloads[urlString] {
            if(download.isDownloading) {
                download.isDownloading = false
                download.downloadTask?.cancel { data in
                    if data != nil {
                        download.downloadTask?.suspend()
                        download.resumeData = data
                    }
                }
            }
        }
    }
    
    // Called when the Resume button for a VideoDetail is tapped
    func resumeDownload(_ videoDetail: VideoDetail) {
        if let urlString = videoDetail.image,
            let download = activeDownloads[urlString] {
            if let resumeData = download.resumeData {
                download.downloadTask = downloadsSession.downloadTask(withResumeData: resumeData)
                download.downloadTask!.resume()
                download.isDownloading = true
            } else if let url = URL(string: download.url) {
                download.downloadTask = downloadsSession.downloadTask(with: url)
                download.downloadTask!.resume()
                download.isDownloading = true
            }
        }
    }
    
    
    // Called when the Cancel button for a VideoDetail is tapped
    func cancelDownload(_ videoDetail: VideoDetail) {
        if let urlString = videoDetail.image,
            let download = activeDownloads[urlString] {
            download.downloadTask?.cancel()
            activeDownloads[urlString] = nil
        }
    }
    
    //MARK:- Cell Button VideoPlay
    func videoPlay(sender:UIButton) {
        print("Video Play")
        let videoDetailIndex = sender.tag
        let videoDetail = arrayData[videoDetailIndex]
        let strUrl = videoDetail.image! as String
        let videoURL = URL(string: strUrl)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        DispatchQueue.main.async(execute: {
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        })
    }
    
    //MARK:- Cell Button DocumentWatch
    func documentWatch(sender:UIButton) {
        print("Document Watch")
        let videoDetailIndex = sender.tag
        print(videoDetailIndex)
        let indexValue = dicForDocumentIndex[videoDetailIndex]
        let previewItem = arrayURLs[indexValue!] as QLPreviewItem
        qlControllerobj = QLPreviewController()
        if qlControllerobj.dataSource == nil && qlControllerobj.delegate == nil {
            qlControllerobj.dataSource = self
            qlControllerobj.delegate = self
        }
        DispatchQueue.main.async {
            if QLPreviewController.canPreview(previewItem) {
                self.qlControllerobj.view.tag = videoDetailIndex
                self.qlControllerobj.currentPreviewItemIndex = indexValue!
                self.present(self.qlControllerobj, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- File Path Methods
    // This method get File Path Url
    func localFilePathForUrl(_ previewUrl: String) -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        if let url = URL(string: previewUrl) {
            let lastPathComponent = url.lastPathComponent
            let fullPath = documentsPath.appendingPathComponent(lastPathComponent)
            return URL(fileURLWithPath:fullPath)
        }
        return nil
    }
    
    // This method checks if the local file exists at the path generated by localFilePathForUrl(_:)
    func localFileExistsForVideoDetail(_ videoDetail: VideoDetail) -> Bool {
        if let urlString = videoDetail.image
        {
            let localUrl = localFilePathForUrl(urlString)
            var isDir : ObjCBool = false
            if let path = localUrl?.path {
                return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            }
        }
        return false
    }
    
    // This method first check both url and get index of url from array
    func videoDetailIndexForDownloadTask(_ downloadTask: URLSessionDownloadTask) -> Int? {
        if let url = downloadTask.response?.url?.absoluteString {
            for (index, videoDetail) in arrayData.enumerated() {
                if url == videoDetail.image {
                    return index
                }
            }
        }
        return nil
    }
    
    //This Method Make Dictionary for index of tableview and array for document
    func documentArrayFill(videoDetail: VideoDetail, indexValue: Int)  {
        let urlPath = localFilePathForUrl(videoDetail.image!)
        if let fileURL = urlPath {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if !arrayURLs.contains(fileURL) {
                    dicForDocumentIndex[indexValue] = arrayURLs.count
                    arrayURLs.append(fileURL)
                }
            }
        }
    }
}

// MARK: - NSURLSessionDelegate
extension ViewController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async(execute: {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                    appDelegate.backgroundSessionCompletionHandler = nil
                    completionHandler()
                }
                else {
                    print("issue in completionHandler")
                }
            }
        })
    }
}

// MARK: - NSURLSessionDownloadDelegate
extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        if let originalURL = downloadTask.response?.url?.absoluteString,
            let destinationURL = localFilePathForUrl(originalURL) {
            print(destinationURL)
            // 2
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: destinationURL)
            } catch {
                // Non-fatal: file probably doesn't exist
            }
            do {
                try fileManager.copyItem(at: location, to: destinationURL)
            } catch let error as NSError {
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
        }
        
        if let url = downloadTask.response?.url?.absoluteString {
            if let videoDetailIndex = videoDetailIndexForDownloadTask(downloadTask) {
                let videoDetail = arrayData[videoDetailIndex]
                DispatchQueue.main.async {
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    print(videoDetail.email ?? "")
                    appdelegate.strTitle =  videoDetail.email! as NSString
                    print(appdelegate.strTitle)
                    let state = UIApplication.shared.applicationState
                    if state == .background {
                        // background
                        appdelegate.localNotification()
                    }
                }
            }
            
            activeDownloads[url] = nil
            
            if let videoDetailIndex = videoDetailIndexForDownloadTask(downloadTask) {
                DispatchQueue.main.async(execute: {
                    self.tblDetails.reloadRows(at: [IndexPath(row: videoDetailIndex, section: 0)], with: .none)
                })
            }
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // 1
        if let downloadUrl = downloadTask.response?.url?.absoluteString,
            let download = activeDownloads[downloadUrl] {
            // 2
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            // 3
           // print(totalBytesWritten)
          //  print(download.progress)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            // 4
            if let videoDetailIndex = videoDetailIndexForDownloadTask(downloadTask) {
                DispatchQueue.main.async {
                    if let videoDetailCell = self.tblDetails.cellForRow(at: IndexPath(row: videoDetailIndex, section: 0)) as? simpleCell {
                        print(videoDetailIndex)
                        print(totalSize)
                        //VideoDetailCell.progressView.progress = download.progress
                        // VideoDetailCell.progressLabel.text =  String(format: "%.1f%% of %@",  download.progress * 100, totalSize)
                        let str = String(format: "%.1f%%",  download.progress * 100)
                        //   print("downloaded Value:\(str)")
                        
                        videoDetailCell.progressView.progress = download.progress
                        videoDetailCell.btnDownload.setTitle(str, for: .normal)
                        if videoDetailCell.btnDownload.backgroundColor != UIColor.green{
                            videoDetailCell.btnDownload.backgroundColor = UIColor.green
                            videoDetailCell.btnDownload.setBackgroundImage(nil, for: .normal)
                        }
                    } else {
                        print("Cell is nil")
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error != nil) {
            print("Download completed with error \(error?.localizedDescription)")
            if let downloadUrl = task.response?.url?.absoluteString,
                let download = activeDownloads[downloadUrl] {
                DispatchQueue.main.async(execute: {
                    if let videoDetailIndex = self.videoDetailIndexForDownloadTask(task as! URLSessionDownloadTask), let videoDetailCell = self.tblDetails.cellForRow(at: IndexPath(row: videoDetailIndex, section: 0)) as? simpleCell {
                        
                        let str = String(format: "%.1f%%",  download.progress * 100)
                        print("downloaded Value:\(str)")
                        videoDetailCell.progressView.progress = download.progress
                        videoDetailCell.btnDownload.setTitle(str, for: .normal)
                        if videoDetailCell.btnDownload.currentBackgroundImage != nil{
                            videoDetailCell.btnDownload.setBackgroundImage(nil, for: .normal)
                        }
                        
                    }  })
            }
        }
        else{
            print("Download finished successfully.")
        }
    }
}

//MARK:- PowerWebserviceDelegate
extension ViewController : PowerWebserviceDelegate {
    /// This will return response from webservice if request successfully done to server
    func powerWebserviceResponseSuccess(response: NSDictionary, apiIdentifier: String) {
        //Constant.hideLoadingHUD()
        view.hideLoadingHUD()
        if apiIdentifier == "GETWebservice" {
            
            if let array: AnyObject = response.object(forKey: "data") as AnyObject? {
                for VideoDetailDictonary in array as! [AnyObject] {
                    if let videoDetailDictonary = VideoDetailDictonary as? [String: AnyObject], let email = VideoDetailDictonary["email"] as? String {
                        // Parse the search result
                        let image = videoDetailDictonary["image"] as? String
                        let lat = videoDetailDictonary["lat"] as? String
                        let long = videoDetailDictonary["long"] as? String
                        let username = videoDetailDictonary["username"] as? String
                        arrayData.append(VideoDetail(email: email, image: image, lat: lat, long: long, username: username))
                    } else {
                        print("Not a dictionary")
                    }
                }
            } else {
                print("Results key not found in dictionary")
            }
            tblDetails.reloadData()
        }
        else if apiIdentifier == "POSTWebservice" {
        }
        else if apiIdentifier == "POSTWithImageWebservice" {
        }
        else if apiIdentifier == "POSTWithFileWebservice" {
        }
    }
    /// This will return response from webservice if request fail to server
    func powerWebserviceResponseFail(response: NSDictionary, apiIdentifier: String) {
        //Constant.hideLoadingHUD()
        Constant.HideHud()
        print(response)
        if apiIdentifier == "GETWebservice" {
        }
        else if apiIdentifier == "POSTWebservice" {
        }
        else if apiIdentifier == "POSTWithImageWebservice" {
        }
        else if apiIdentifier == "POSTWithFileWebservice" {
        }
    }
    /// This is for Fail request or server give any error
    func powerWebserviceResponseError(error: Error?, apiIdentifier: String) {
         Constant.hideLoadingHUD()
         Constant.HideHud()
    }
}

//MARK:- UITableViewDataSource
extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: simpleCell = tableView.dequeueReusableCell(withIdentifier: "simpleCell") as! simpleCell
        
        let videoDetail = arrayData[indexPath.row]
        cell.lblName.text = videoDetail.username
        cell.lblEmail.text = videoDetail.email
        
        //Button Pause Or Resume Given Action
        cell.btnPauseResume.tag = indexPath.row
        cell.btnPauseResume.addTarget(self, action: #selector(ViewController.btnPauseResumeAction(sender:)), for: .touchUpInside)
        
        //Button btnCancel Given Action
        cell.btnCancel.tag = indexPath.row
        cell.btnCancel.addTarget(self, action: #selector(ViewController.btnCancelDownloadAction(sender:)), for: .touchUpInside)
    
        //Button btnDownload Given Action
        cell.btnDownload.tag = indexPath.row
        cell.btnDownload.addTarget(self, action: #selector(ViewController.btnDownloadAction(sender:)), for: .touchUpInside)
        
        //var showDownloadControls = false
        if let download = activeDownloads[videoDetail.image!] {
            //showDownloadControls = true
            
            //This Contsraint For When Click on Download Button
            cell.constrViewDownHeight.constant = 25.0
            cell.viewDown.isHidden = false
            cell.progressView.progress = download.progress
            
            let str = String(format: "%.1f%%",  download.progress * 100)
            cell.btnDownload.setTitle(str, for: .normal)

//            cell.lblProgress.text = (download.isDownloading) ? "Downloading..." : "Paused"
            let title = (download.isDownloading) ? "Pause" : "Resume"
            cell.btnPauseResume.setTitle(title, for: .normal)
            cell.btnDownload.setBackgroundImage(nil, for: .normal)
        }
        else {
            cell.btnDownload.setBackgroundImage(#imageLiteral(resourceName: "iconNew"), for: .normal)
            cell.btnDownload.setTitle("", for: .normal)
            cell.constrViewDownHeight.constant = 0.0
            cell.viewDown.isHidden = true
        }
        cell.btnDownload.layer.cornerRadius = cell.btnDownload.frame.size.width/2
        cell.btnDownload.layer.masksToBounds = true
        let downloaded = localFileExistsForVideoDetail(videoDetail)
      ///  cell.btnDownload.isHidden = downloaded || showDownloadControls
        
        let urlPath = URL(string: videoDetail.image! as String)
        if downloaded {
           if let pathExtension = urlPath?.pathExtension {
             cell.btnDownload.tag = indexPath.row
            switch pathExtension {
            case "mp4":
                cell.btnDownload.isHidden = false
                cell.btnDownload.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
                cell.btnDownload.setTitle("", for: .normal)
            case "pdf", "rtf", "png":
                cell.btnDownload.isHidden = false
                cell.btnDownload.setBackgroundImage(#imageLiteral(resourceName: "eye"), for: .normal)
                cell.btnDownload.setTitle("", for: .normal)
                documentArrayFill(videoDetail: videoDetail, indexValue: indexPath.row)
            default:
                 cell.btnDownload.isHidden = true
            }
           }
        }
        else {
        }
        cell.btnDownload.backgroundColor = UIColor.lightGray
        cell.layoutMargins = .zero
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
}

//MARK:- UITableViewDelegate
extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select index")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK:- QLPreviewControllerDataSource
extension ViewController : QLPreviewControllerDataSource {
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return arrayURLs[index] as QLPreviewItem
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return arrayURLs.count
    }
}

//MARK:- QLPreviewControllerDelegate
extension ViewController:QLPreviewControllerDelegate {
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        let tagValue = controller.view.tag as Int
        let indexpath = IndexPath(row: tagValue, section: 0)
        tblDetails.deselectRow(at: indexpath, animated: true)
        print("The Preview Controller has been dismissed.")
    }
}

//MARK:- UIDocumentInteractionControllerDelegate
extension ViewController:UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}
