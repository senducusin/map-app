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
    private lazy var searchInputView: SearchInputView = {
        let view = SearchInputView()
        view.delegate = self
        return view
    }()
    
    private let mapView: MKMapView = {
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
    
    private var centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.addTarget(self, action: #selector(centerMapButtonHandler), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = .init(width:0, height:4)
        button.layer.shadowColor = UIColor.black.cgColor
        return button
    }()
    
    var constraintsBottom: NSLayoutConstraint?
    
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
    
    // MARK: - Selectors
    @objc private func centerMapButtonHandler(){
        centerMapOnUserLocation()
    }
    
    // MARK: - Helpers
    private func setupUI(){
        view.backgroundColor = .green
        
        setupMapView()
        setupSearchInputView()
        setupCenterMapButton()
    }
    
    private func setupCenterMapButton(){
        view.addSubview(centerMapButton)
        centerMapButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            right: view.safeAreaLayoutGuide.rightAnchor,
            paddingTop: 10,
            paddingRight: 15,
            width: 50,
            height: 50)
    }
    
    private func setupMapView(){
        view.addSubview(mapView)
        mapView.fillView(view: view)
    }
    
    private func setupSearchInputView(){
        view.addSubview(searchInputView)
        searchInputView.centerX(inView: view)
        
        searchInputView.anchor(left: view.leftAnchor, right: view.rightAnchor, height: view.frame.height)
            
        constraintsBottom = searchInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height - 88)
        constraintsBottom?.isActive = true
        
    }
    
    private func enableLocationServices(){
        switch locationManager.authorizationStatus {
        
        case .notDetermined:
            DispatchQueue.main.async {
                self.presentLocationRequestController()
            }
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
    
    private func animateInputView(targetPosition: CGFloat){
        constraintsBottom?.isActive = false
        constraintsBottom = searchInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: targetPosition)
        
        UIView.animate(withDuration: 0.5,delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.constraintsBottom?.isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    func searchBy(naturalLanguageQuery: String, region: MKCoordinateRegion, coordinates: CLLocationCoordinate2D, completion:@escaping(_ response: MKLocalSearch.Response?, _ error: NSError?)->()){
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = naturalLanguageQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                if let error = error as NSError? {
                    completion(nil,error)
                }
                return
            }
            
            completion(response,nil)
        }
    }
}

extension MapController: SearchInputViewDelegate {
    func searchInputViewShouldStartSearch(withSearchText searchText: String) {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        searchBy(naturalLanguageQuery: searchText, region: region, coordinates: coordinate) { response, error in
            response?.mapItems.forEach({ mapItem in
                print("DEBUG: \(mapItem.name)")
            })
        }
    }
    
    func searchInputViewShouldUpdatePosition(searchInputView: SearchInputView, targetPosition: CGFloat, state: ExpansionState) {
        animateInputView(targetPosition: targetPosition)
        if state == .FullyExpanded {
            centerMapButton.isHidden = true
        }else{
            centerMapButton.isHidden = false
        }
    }
}
