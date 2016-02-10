//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/5/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var uniqueKey: String 
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var dictionary: [String: AnyObject] {
        return [
            "firstName" : firstName,
            "lastName" : lastName,
            "latitude" : latitude,
            "longitude" : longitude,
            "mapString" : mapString,
            "mediaURL" : mediaURL,
        ]
    }
    
    init(uniqueKey: String, firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String, mediaURL: String){
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
    }
    
    init(dictionary: [String: AnyObject]){
        uniqueKey = dictionary["uniqueKey"] as! String
        firstName = dictionary["firstName"] as! String
        lastName  = dictionary["lastName"] as! String
        latitude  = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mapString = dictionary["mapString"] as! String
        mediaURL  = dictionary["mediaURL"] as! String
    }
}