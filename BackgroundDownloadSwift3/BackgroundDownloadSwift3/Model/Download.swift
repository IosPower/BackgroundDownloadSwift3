//
//  Download.swift
//  BackgroundDownloadSwift3
//
//  Created by piyush sinroja on 19/04/17.
//  Copyright © 2017 Piyush. All rights reserved.

import Foundation
class Download: NSObject {
  var url: String
  var isDownloading = false
  var progress: Float = 0.0
  var downloadTask: URLSessionDownloadTask?
  var resumeData: Data?

  init(url: String) {
    self.url = url
  }
}
