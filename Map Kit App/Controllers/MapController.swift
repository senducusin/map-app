//
//  MapController.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate{
    // MARK: - Properties
    var searchInputView: SearchInputView = {
        let view = SearchInputView()
        
        return view
    }()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        centerMapOnUserLocation()
    }
    
    // MARK: - Helpers
    private func setupUI(){
        view.backgroundColor = .green
        
        setupMapView()
        setupSearchInputView()
    }
    
    private func setupMapView(){
        view.addSubview(mapView)
        mapView.fillView(view: view)
    }
    
    private func setupSearchInputView(){
        view.addSubview(searchInputView)
        searchInputView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: -(view.frame.height - 88), height: view.frame.height)
    }
    
    private func enableLocationServices(){
        switch locationManager.authorizationStatus {
        
        case .notDetermined:
            presentLocationRequestController()
        default:
            break
        }
    }
    
    private func presentLocationRequestController(){
        let controller = LocationRequestController()
        controller.locationManager = self.locationManager
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    private func centerMapOnUserLocation(){
        guard let coordinates = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
