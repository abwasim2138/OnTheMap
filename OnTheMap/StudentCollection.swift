//
//  StudentCollection.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/5/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import Foundation

class StudentCollection {
    
    static let studentCollection = StudentCollection()
    var students = [StudentInformation]()
    var myAccount:NSDictionary?
    
    
    func getInfo (array: [[String: AnyObject]]) {
        students.removeAll()
        for dictionary in array {
        let student = StudentInformation(dictionary: dictionary)
        students.append(student)
        }
    }
}