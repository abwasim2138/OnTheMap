//
//  InformationPostingVC.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/5/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostingVC: UIViewController, MKMapViewDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    private var locManager = CLLocationManager()
    private var mapView: MKMapView!
    private var isSubmitTime = false
    private let geoCoder = CLGeocoder()
    private var changedLocation = false
    private var mapString = String()
    private var coord = CLLocation()
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var findAndSubmit: UIButton!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var questionStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //SET UP MAPVIEW
        mapView = MKMapView(frame: CGRect(x: 0, y: view.frame.height/3, width: view.frame.width, height: view.frame.height))
        self.view.addSubview(mapView)
        mapView.hidden = true
        
        //BUTTON LOOKS
        findAndSubmit.layer.cornerRadius = 10
        
        //NAVBAR TRANSPARENCY
        if let navBar = navigationController?.navigationBar {
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
        }
        
        //SET UP LOCATION MANAGER
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()
        
        //DELEGATES
        locManager.delegate = self
        mapView.delegate = self
        infoTextView.delegate = self
        
    }

    //MARK: METHODS
    
    func alertUser(title: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okayAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func findOnTheMap () {
        
        mapView.hidden = false
        mapView.alpha = 0.0
        cancel.tintColor = UIColor.whiteColor()
        let moveBy = ((self.navigationController?.navigationBar.frame.origin.y)! - self.infoTextView.frame.origin.y)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.infoTextView.transform = CGAffineTransformMakeTranslation(0, moveBy)
            self.mapView.alpha = 1.0
            self.view.bringSubviewToFront(self.findAndSubmit)
        }
        infoTextView.text = "Enter A Link To Share Here"
        infoTextView.resignFirstResponder()
        findAndSubmit.setTitle("Submit", forState: .Normal)
        questionStackView.hidden = true
        isSubmitTime = true
    }
    
    func submitInfo () {
        if let account = StudentCollection.studentCollection.myAccount {
        let student = StudentInformation(uniqueKey: "OPTIONAL", firstName: account["first_name"] as! String, lastName: account["last_name"] as! String, latitude: coord.coordinate.latitude, longitude: coord.coordinate.longitude,mapString: mapString, mediaURL: infoTextView.text)
        findAndSubmit.setTitle("POSTING", forState: .Normal)
        APIClient.postInfo(student, completionHandler: { (result, error) -> Void in
            if error != nil {
                return self.alertUser("COULDN'T POST YOUR INFO")
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            })
        }
    }
    
    
    //MARK: UIACTIONS
    
    @IBAction func findAndSubmit(sender: UIButton) {
        if isSubmitTime {
            submitInfo()
        }else{
            if changedLocation || infoTextView.text.containsString("ENTER A LOCATION HERE"){
                geocodeString()
            }else{
                findOnTheMap()
            }
        }
        
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: TEXTVIEW DELEGATE & RELATED METHODS
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView == infoTextView {
            changedLocation = true
            if textView.text == "Enter A Link To Share Here" {
                textView.text = "http://"
            }else{
                textView.text = ""
            }
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    //MARK: GET CURRENT LOCATION
    
    func reverseGeocode (currLoc: CLLocation) {
        geoCoder.reverseGeocodeLocation(currLoc, completionHandler: { (placemarks, error) -> Void in
            if let placeMark = placemarks?.first {
                self.infoTextView.text = "\(placeMark.locality!) \(placeMark.administrativeArea!)"
                self.makeAnnotation(currLoc)
                self.mapString = self.infoTextView.text
                self.coord = placeMark.location!
            }
        })
    }
    
    func geocodeString(){
        if let mapString = infoTextView.text {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y)
        activityIndicator.startAnimating()
        geoCoder.geocodeAddressString(mapString) { (placemarks, error) -> Void in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            guard error == nil else {
                self.alertUser("TROUBLE FINDING IT ON THE MAP")
                return
            }
            if let placeMark = placemarks?.first {
                self.makeAnnotation(placeMark.location!)
                self.mapString = mapString
                self.coord = placeMark.location!
                self.findOnTheMap()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locManager.stopUpdatingLocation()
        if let coord = locations.first?.coordinate {
            let lat = coord.latitude
            let long = coord.longitude
            let currLoc = CLLocation(latitude: lat, longitude: long)
            reverseGeocode(currLoc)
        }
    }
    //MARK: - ANNOTATIONS
    
    func makeAnnotation(currLoc: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: currLoc.coordinate.latitude, longitude: currLoc.coordinate.longitude)
        self.mapView.setRegion(MKCoordinateRegion(center: currLoc.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.5), longitudeDelta: CLLocationDegrees(0.5))), animated: true)
        self.mapView.addAnnotations([annotation])
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin") 
        pinView!.pinTintColor = .redColor()
        }else{
        pinView?.annotation = annotation
        }
        return pinView
    }
    

}
