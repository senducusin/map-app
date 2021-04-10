//
//  MapController.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController{
    // MARK: - Properties
    var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }()
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        return locationManager
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        enableLocationServices()
    }
    
    // MARK: - Helpers
    private func setupUI(){
        view.backgroundColor = .green
        
        view.addSubview(mapView)
        mapView.fillView(view: view)
    }
    
    private func enableLocationServices(){
        switch locationManager.authorizationStatus {
        
        case .notDetermined:
            let controller = LocationRequestController()
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }
    
}

extension MapController: CLLocationManagerDelegate {
    
}
