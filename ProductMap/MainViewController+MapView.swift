//
//  MainViewController+MapView.swift
//  ProductMap
//
//  Created by Trevin Wisaksana on 4/15/17.
//  Copyright © 2017 Trevin Wisaksana. All rights reserved.
//

import UIKit
import MapKit

extension MainViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    // MARK: - Map View Method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        // View
        var annotationView: MKAnnotationView?
        guard let annotation = annotation as? Product else {
            return nil
        }
        
        let id = annotation.identifier
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: id) {
            // Set the view to the dequeued view
            annotationView = dequeuedView
        } else {
            // Make a new view
            annotationView = AnnotationView(
                annotation: annotation,
                reuseIdentifier: id
            )
            annotationView?.canShowCallout = false
        }
        
        if let annotationView = annotationView {
            // Resizing the image because the image.size is a get only property
            let image = UIImage(named: "pinImage")
            
            let size = CGSize(
                width: 25,
                height: 72
            )
            
            UIGraphicsBeginImageContext(size)
            
            let rectangle = CGRect(
                x: 0,
                y: 0,
                width: size.width,
                height: size.height
            )
            
            image?.draw(in: rectangle)
            
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            annotationView.image = resizedImage
        }
   
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // If view.annotation is type MKUserLocation
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        
        // TODO: Add in constants file
        let width = self.view.frame.width
        let height = self.view.frame.height
        let calloutViewHeight = self.view.frame.height * 0.2
        
        // Custom annotation
        guard let productAnnotation = view.annotation as? Product else {
            return
        }
        
        APIClient.sharedInstance.getProduct(
            with: productAnnotation.id!,
            city: productAnnotation.city) { (product) in
                
                // Custom callout view
                let calloutView = CustomCalloutView()
                
                // Setup calloutView
                calloutView.configure(with: product)
                
                // Setup frame
                calloutView.frame = CGRect(
                    x: 0,
                    y: height,
                    width: width,
                    height: calloutViewHeight
                )
                
                // Animates the entry of the calloutView
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    // Animating the calloutView
                    calloutView.frame.origin.y = height * 0.84
                })
                
                // Adding the calloutView to the Map View
                self.view.addSubview(calloutView)
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        let calloutViewYPosition = self.view.frame.height

        // If the view is type AnnotationView
        if view.isKind(of: AnnotationView.self) {
            for subview in self.view.subviews {
                if subview.isKind(of: CustomCalloutView.self) {
                    
                    // Animating the removal of the calloutView
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.frame.origin.y = calloutViewYPosition
                    }, completion: { (_) in
                        // Remove the subview
                        subview.removeFromSuperview()
                    })
                }
                
            }
            
        }

    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        // Dragging states
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default:
            break
        }
    }
    
    
    // MARK: - CLLocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // Getting user location
        guard let currentLocation = manager.location?.coordinate else {
            return
        }
        // Setting the center of the map to the user location
        mainMapView.setCenter(currentLocation, animated: false)
        // Getting the region to focus
        let region = MKCoordinateRegionMakeWithDistance(
            currentLocation,
            5000,
            5000
        )
        self.mainMapView.setRegion(region, animated: false)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.verbose(error)
    }

    
    func revealSearchView() {
        // Display searchView
        searchView.showSearchView()
        // Display the searchCollectionView
        searchCollectionView.showSearchCollectionView()
        // Place the Bottom Bar View at the back
        self.view.sendSubview(toBack: bottomBarView)
        // Disable the map from being scrollable
        mainMapView.isUserInteractionEnabled = false
    }
    
    
    func dismissSearchView() {
        // Dismiss searchView
        searchView.dismissSearchView()
        // Hide the searchCollectionView
        searchCollectionView.dismissSearchCollectionView()
        // Place the Bottom Bar View at the back
        self.view.bringSubview(toFront: bottomBarView)
        // Enable map view
        mainMapView.isUserInteractionEnabled = true
        // Hide keyboard
        searchTextField.resignFirstResponder()
    }
    
}
