//  MapViewController.swift
//  Notes
//  Created by Mac on 3/26/18.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit
import MapKit
class MapViewController: UIViewController {

    var loactionData:String?    //Stores Longitude and latitude
    var noteTitle:String?        //Name of User
    @IBOutlet var mapView: MKMapView!   //Map View Outlet
    
    override func viewDidLoad() {       //View Load Runs To App Startup
        super.viewDidLoad()
        
        var coordinate = loactionData?.components(separatedBy: ",")
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01) 
        let Location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(coordinate![0])!,Double(coordinate![1])!)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(Location, span)
        mapView.setRegion(region, animated: true)
        let Marker = MKPointAnnotation()
        
        Marker.coordinate = Location
        Marker.title = noteTitle
       
        mapView.addAnnotation(Marker)
        
        

    }
    
    
}
