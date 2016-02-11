//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/4/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    private var annotations = [MKAnnotation]()
    private var isPinView = false
    private var oldRegion = MKCoordinateRegion()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //DELEGATES
        mapView.delegate = self
        getData()
    }
 
    func getData () {
        if annotations.count == 0 {
            APIClient.getRequestedData({ (success, error) -> Void in
                guard error == nil && success == true else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alertController = UIAlertController(title: "Failed To Download Info", message: "", preferredStyle: .Alert)
                        let okayAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(okayAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                return
                }
            })
            for student in StudentCollection.studentCollection.students {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
                annotation.title = "\(student.firstName) \(student.lastName)"
                annotation.subtitle = student.mediaURL
                annotations.append(annotation)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotations(self.annotations)
            })
        }
    }
        //MARK: MKMAPVIEW 
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView!.canShowCallout = true
        pinView!.pinTintColor = UIColor.orangeColor()
        pinView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        pinView?.animatesDrop = true
        }else{
        pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        isPinView = true
        oldRegion = mapView.region
        let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: MKCoordinateSpanMake(CLLocationDegrees(0.5), CLLocationDegrees(0.5)))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var http = "http://"
        if let urlString = view.annotation!.subtitle! {
            if urlString.containsString("//") == true {
                http = ""
            }
            if let url = NSURL(string: http + urlString) {
             UIApplication.sharedApplication().openURL(url) 
            }
        }
    }

    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        getData()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isPinView {
            mapView.setRegion(oldRegion, animated: true)
            isPinView = false
        }
    }

    @IBAction func refresh(sender: UIBarButtonItem) {
        //StudentCollection.studentCollection.students.removeAll()
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        getData()
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        let activityView = UIActivityIndicatorView()
        activityView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(activityView)
        activityView.startAnimating()
        APIClient.logout { (result, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else{
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
}

