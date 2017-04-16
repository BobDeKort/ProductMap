//
//  MainMapView.swift
//  ProductMap
//
//  Created by Trevin Wisaksana on 4/12/17.
//  Copyright © 2017 Trevin Wisaksana. All rights reserved.
//


import UIKit
import MapKit

class MainMapView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        resetRegion()
        // Cleans the map
        showsPointsOfInterest = false
        // Setting user location
        showsUserLocation = true
        // Map type
        mapType = MKMapType.standard
        // Setup gesture recognizer
        setupLongTapGesture()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /// Starts the map with a location in Chicago.
    /// It is set for testing.
    func resetRegion() {
        // For testing
        let chicagoCoordinate = CLLocationCoordinate2DMake(41.8832301, -87.6278121)
        let region = MKCoordinateRegionMakeWithDistance(chicagoCoordinate, 5000, 5000)
        self.setRegion(region, animated: true)
    }
    
    
    fileprivate func setupLongTapGesture() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressHandler)
        )
        
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    
    /// Adds a pin on the MapView when the user long presses
    ///
    /// - Parameter gestureRecognizer: Default UIGestureRecognizer
    @objc fileprivate func longPressHandler(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: self)
        // Converts the touch point to a coordinate
        let touchMapCoordinate = self.convert(touchPoint, toCoordinateFrom: self)
        let latitude = touchMapCoordinate.latitude
        let longitude = touchMapCoordinate.longitude
        
        let productLocation = ProductLocation(
            name: "Product",
            latitude: latitude,
            longitude: longitude
        )
        
        // Adds the notation
        self.addAnnotation(productLocation)
    }
    
}
