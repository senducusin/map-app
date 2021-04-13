//
//  MapController.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit
import MapKit

class MapController: UIViewController, CLLocationManagerDelegate{
    // MARK: - Properties
    private lazy var searchInputView: SearchInputView = {
        let view = SearchInputView()
        view.delegate = self
        view.mapController = self
        return view
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
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
        button.image(for: .normal)
        button.addTarget(self, action: #selector(centerMapButtonHandler), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = .init(width:0, height:4)
        button.layer.shadowColor = UIColor.black.cgColor
        return button
    }()
    
    private var removeOverlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(removeOverlayHandler), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.alpha = 0
        
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = .init(width:0, height:4)
        button.layer.shadowColor = UIColor.black.cgColor
        return button
    }()
    
    var viewModel = MapControllerViewModel()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        enableLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerMapOnUserLocation()
        loadAnnotationResult(withQuery: "Restaurants")
    }
    
    // MARK: - Selectors
    @objc private func centerMapButtonHandler(){
        centerMapOnUserLocation()
    }
    
    @objc private func removeOverlayHandler(){
        guard let _ = viewModel.selectedAnnotation else {return}
        
        shouldShowRemoveOverlayButton(false)
        removeOverlay()
        centerMapOnUserLocation()
    }
    
    // MARK: - Helpers
    private func removeOverlay(){
        guard let selectedAnnotation = viewModel.selectedAnnotation else {return}
        
        if mapView.overlays.count > 0 {
            self.mapView.removeOverlay((mapView.overlays[0]))
        }
        
        mapView.deselectAnnotation(selectedAnnotation, animated: true)
    }
    
    private func setupUI(){
        view.backgroundColor = .green
        
        setupMapView()
        setupSearchInputView()
        setupCenterMapButton()
        setupRemoveOverlayButton()
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
    
    private func setupRemoveOverlayButton(){
        view.addSubview(removeOverlayButton)
        removeOverlayButton.anchor(
            top: centerMapButton.bottomAnchor,
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
        
        viewModel.searchInputViewBottomConstraint = searchInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height - 88)
    }
    
    private func presentLocationRequestController(){
        let controller = LocationRequestController()
        controller.locationManager = self.locationManager
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    private func animateInputView(targetPosition: CGFloat){
        viewModel.disableSearchViewConstraint()
        viewModel.searchInputViewBottomConstraint = searchInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: targetPosition)
        
        UIView.animate(withDuration: 0.5,delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
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
    
    // MARK: - Map Helpers
    private func zoomToFit(selectedAnnotation: MKAnnotation?){
        guard mapView.annotations.count > 0,
              let selectedAnnotation = selectedAnnotation else {return}
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in mapView.annotations {
            if let userAnnotation = annotation as? MKUserLocation {
                topLeftCoordinate.longitude = min(topLeftCoordinate.longitude, userAnnotation.coordinate.longitude)
                
                topLeftCoordinate.latitude = max(topLeftCoordinate.latitude, userAnnotation.coordinate.latitude)
                
                bottomRightCoordinate.longitude = max(bottomRightCoordinate.longitude, userAnnotation.coordinate.longitude)
                
                bottomRightCoordinate.latitude = min(bottomRightCoordinate.latitude, userAnnotation.coordinate.latitude)
                
            }
            
            if viewModel.compareAnnotations(annotationA: selectedAnnotation, annotationB: annotation) {
                
                topLeftCoordinate.longitude = min(topLeftCoordinate.longitude, selectedAnnotation.coordinate.longitude)
                
                topLeftCoordinate.latitude = max(topLeftCoordinate.latitude, selectedAnnotation.coordinate.latitude)
                
                bottomRightCoordinate.longitude = max(bottomRightCoordinate.longitude, selectedAnnotation.coordinate.longitude)
                
                bottomRightCoordinate.latitude = min(bottomRightCoordinate.latitude, selectedAnnotation.coordinate.latitude)
                
            }
        }
        
        var region = viewModel.getZoomRegion(topLeftCoordinate: topLeftCoordinate, bottomRightCoordinate: bottomRightCoordinate)
        
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    

    
    private func drawPolyline(forDestinationMapItem destinationMapItem: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destinationMapItem
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let response = response,
                  error == nil else {return}
            
            self?.viewModel.route = response.routes[0] // first index is usually the fastest
            self?.shouldShowRemoveOverlayButton(true)
            
            guard let route = self?.viewModel.route else {return}
            
            let polyline = route.polyline
            self?.mapView.addOverlay(polyline)
        }
    }
    
    private func shouldShowRemoveOverlayButton(_ show: Bool){
        UIView.animate(withDuration: 0.5) {
            self.removeOverlayButton.alpha = show ? 1 : 0
        }
    }
    
    private func enableLocationServices(){
        if locationManager.authorizationStatus == .notDetermined {
            DispatchQueue.main.async {
                self.presentLocationRequestController()
            }
        }
    }
    
    private func centerMapOnUserLocation(){
        guard let coordinates = locationManager.location?.coordinate else { return }
        mapView.setRegion(viewModel.getCenterRegion(withCoordinate: coordinates), animated: true)
    }
    
    func clearAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func loadAnnotationResult(withQuery query:String){
        guard let coordinate = locationManager.location?.coordinate else {return}
        searchBy(naturalLanguageQuery: query, region: viewModel.getSearchRegion(withCoordinate: coordinate), coordinates: coordinate) { [weak self] response, error in
            
            if let mapItems = response?.mapItems {
                
                mapItems.forEach({ mapItem in
                    let annotation = MKPointAnnotation()
                    annotation.title = mapItem.name
                    annotation.coordinate = mapItem.placemark.coordinate
                    self?.mapView.addAnnotation(annotation)
                })
                
                self?.searchInputView.mapItems = mapItems
            }
        }
    }
}

// MARK: - SearchInputView Delegate
extension MapController: SearchInputViewDelegate {
    func selectAnnotation(withMapItem mapItem: MKMapItem) {
        for annotation in mapView.annotations {
            if viewModel.compareMapItemToAnnotation(mapItem: mapItem, annotation: annotation){
                
                mapView.selectAnnotation(annotation, animated: true)
                zoomToFit(selectedAnnotation: annotation)
                viewModel.selectedAnnotation = annotation
                break;
            }
        }
    }
    
    func addPolyline(forDestinationMapItem destinationMapItem: MKMapItem) {
        removeOverlay()
        drawPolyline(forDestinationMapItem: destinationMapItem)
    }
    
    func searchInputViewShouldStartSearch(withSearchText searchText: String) {
        removeOverlayHandler()
        clearAnnotations()
        loadAnnotationResult(withQuery: searchText)
    }
    
    func searchInputViewShouldUpdatePosition(searchInputView: SearchInputView, targetPosition: CGFloat, state: ExpansionState) {
        
        viewModel.searchInputViewState = state
        animateInputView(targetPosition: targetPosition)
        centerMapButton.isHidden = viewModel.shouldShowButton
        removeOverlayButton.isHidden = viewModel.shouldShowButton
    }
}

// MARK: - SearchCell Delegate
extension MapController: SearchCellDelegate {
    func distanceFromUser(location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = locationManager.location else {return nil}
        return userLocation.distance(from: location)
    }
    
    func getDirections(forMapItem mapItem: MKMapItem) {
        let modeWalking = MKLaunchOptionsDirectionsModeWalking
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: modeWalking
        ])
    }
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return viewModel.polylineRenderer()
    }
}
