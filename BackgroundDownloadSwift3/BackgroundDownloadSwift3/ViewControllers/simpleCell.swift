//
//  simpleCell.swift
//  BackgroundDownloadSwift3
//
//  Created by piyush sinroja on 17/04/17.
//  Copyright © 2017 Piyush. All rights reserved.
//

import UIKit
class simpleCell: UITableViewCell {
    @IBOutlet weak var viewDown: UIView!
    @IBOutlet weak var constrViewDownHeight: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var btnPauseResume: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
   
}
