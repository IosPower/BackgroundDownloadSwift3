//
//  VideoDetail.swift
//  BackgroundDownloadSwift3
//
//  Created by piyush sinroja on 19/04/17.
//  Copyright © 2017 Piyush. All rights reserved.
//

class VideoDetail {
  var email: String?
  var image: String?
  var lat: String?
  var long: String?
  var username: String?
    
  // MARK: - Init Model
  init(email: String?, image: String?, lat: String?, long: String?, username: String?) {
    self.email = email
    self.image = image
    self.lat = lat
    self.long = long
    self.username = username
  }
}
