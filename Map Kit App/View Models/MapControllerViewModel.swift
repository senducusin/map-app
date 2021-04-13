//
//  MapControllerViewModel.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/13/21.
//

import Foundation
import MapKit

struct MapControllerViewModel {
    var route: MKRoute?
    var selectedAnnotation: MKAnnotation?
    var searchInputViewState: ExpansionState = .Collapsed
    
    let searchRegionDimension:Double = 2000
    let centerRegionDimension:Double = 10000
    
    var searchInputViewBottomConstraint: NSLayoutConstraint? {
        didSet {
            searchInputViewBottomConstraint?.isActive = true
        }
    }
    
    var shouldShowButton: Bool {
        return searchInputViewState == .FullyExpanded ? false : true
    }
}

extension MapControllerViewModel {
    func polylineRenderer()-> MKOverlayRenderer {
        guard let route = route else { return MKOverlayRenderer() }
        
        let polyline = route.polyline
        let lineRenderer = MKPolylineRenderer(overlay: polyline)
        lineRenderer.strokeColor = .themeBlue
        lineRenderer.lineWidth = 3
        
        return lineRenderer
    }
    
    func disableSearchViewConstraint(){
        searchInputViewBottomConstraint?.isActive = false
    }
    
    func getSearchRegion(withCoordinate coordinate:CLLocationCoordinate2D) -> MKCoordinateRegion{
        return MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: searchRegionDimension,
            longitudinalMeters: searchRegionDimension
        )
    }
    
    func getCenterRegion(withCoordinate coordinate:CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: centerRegionDimension,
            longitudinalMeters: centerRegionDimension
        )
    }
    
    func getZoomRegion(topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let center = CLLocationCoordinate2DMake(
            topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.65,
            topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.65)
        
        let span = MKCoordinateSpan(
            latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 3.0,
            longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 3.0)
        
        return MKCoordinateRegion(center:center, span: span)
    }
    
    func getZoomCoordinateTop(withAnnotation annotation:MKAnnotation, coordinate:CLLocationCoordinate2D) ->CLLocationCoordinate2D {
        
        var newCoordinate = coordinate
        
        newCoordinate.longitude = fmin(newCoordinate.longitude, annotation.coordinate.longitude)
    
        newCoordinate.latitude = fmax(newCoordinate.latitude, annotation.coordinate.latitude)
        
        return newCoordinate
    }
    
    func getZoomCoordinateBottom(withAnnotation annotation:MKAnnotation, coordinate:CLLocationCoordinate2D) ->CLLocationCoordinate2D {
        var newCoordinate = coordinate
        
        newCoordinate.longitude = fmax(newCoordinate.longitude, annotation.coordinate.longitude)
        
        newCoordinate.latitude = fmin(newCoordinate.latitude, annotation.coordinate.latitude)
        
        return newCoordinate
    }
    
    func compareAnnotations(annotationA: MKAnnotation, annotationB: MKAnnotation) -> Bool {
        
        if let titleA = annotationA.title,
           let titleB = annotationB.title{
            
            if titleA != titleB {
                return false
            }
        }else {
            return false
        }
        
        if annotationA.coordinate.latitude != annotationB.coordinate.latitude {
            return false
        }
        
        if annotationA.coordinate.longitude != annotationB.coordinate.longitude {
            return false
        }
        
        print("DEBUG: \(annotationA.coordinate.latitude) \(annotationB.coordinate.latitude) matched!")
        
        return true
    }
    
    func compareMapItemToAnnotation(mapItem: MKMapItem, annotation:MKAnnotation) -> Bool{
        
        if mapItem.name != annotation.title {
            return false
        }
        
        if mapItem.placemark.coordinate.latitude != annotation.coordinate.latitude {
            return false
        }
        
        if mapItem.placemark.coordinate.longitude != annotation.coordinate.longitude {
            return false
        }
        
        return true
    }
}

//print("DEBUG: \(mapItem.name) - \(mapItem.placemark.coordinate)")
//if let userAnnotation = annotation as? MKUserLocation {
//    topLeftCoordinate = viewModel.getZoomCoordinateTop(withAnnotation: userAnnotation, coordinate: topLeftCoordinate)
//
//    bottomRightCoordinate = viewModel.getZoomCoordinateBottom(withAnnotation: userAnnotation, coordinate: bottomRightCoordinate)
//
//}
//
//if annotation.title == selectedAnnotation.title {
//    topLeftCoordinate = viewModel.getZoomCoordinateTop(withAnnotation: annotation, coordinate: topLeftCoordinate)
//
//    bottomRightCoordinate = viewModel.getZoomCoordinateBottom(withAnnotation: annotation, coordinate: bottomRightCoordinate)
//}
