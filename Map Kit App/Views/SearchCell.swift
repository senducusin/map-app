//
//  SearchCell.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit
import MapKit

protocol SearchCellDelegate {
    func getDirections(forMapItem mapItem: MKMapItem)
}

class SearchCell: UITableViewCell {
    // MARK: - Properties
    static let cellIdentifier = "SearchCell"
    
    var place: Place? {
        didSet{
            configure()
        }
    }
    
    private var directionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitle("Go", for: .normal)
        button.backgroundColor = .themeGreen
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(directionButtonHandler), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.alpha = 0
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .themePink
        view.addSubview(locationImageView)
        locationImageView.center(inView: view)
        locationImageView.setHeight(height: 29)
        locationImageView.setWidth(width: 29)
        return view
    }()
    
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .themePink
        imageView.image = UIImage(systemName: "mappin.circle.fill")
        imageView.tintColor = .white
        return imageView
    }()
    
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let locationDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc private func directionButtonHandler(){
        print("DEBUG: directions")
    }
    
    // MARK: - Helpers
    private func setupUI(){
        setupImageContainerView()
        setupLocationTitleLabel()
        setupLocationDistanceLabel()
        setupDirectionsButton()
    }
    
    private func setupDirectionsButton(){
        addSubview(directionsButton)
        directionsButton.anchor(left: locationTitleLabel.rightAnchor, right:rightAnchor, paddingLeft: 8, paddingRight: 17, width: 40, height: 40)
        directionsButton.centerY(inView: self)
    }
    
    private func setupLocationTitleLabel(){
        addSubview(locationTitleLabel)
        locationTitleLabel.anchor(top:imageContainerView.topAnchor, left: imageContainerView.rightAnchor, paddingLeft: 8)
    }
    
    private func setupLocationDistanceLabel(){
        addSubview(locationDistanceLabel)
        locationDistanceLabel.anchor(top:locationTitleLabel.bottomAnchor, left: imageContainerView.rightAnchor, bottom: imageContainerView.bottomAnchor, paddingLeft: 8)
    }
    
    func animateButtonIn(){
        directionsButton.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.directionsButton.alpha = 1
            self.directionsButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    private func setupImageContainerView(){
        addSubview(imageContainerView)
        let dimension:CGFloat = 40
        imageContainerView.anchor(left:leftAnchor, paddingLeft: 17 ,width: dimension, height: dimension)
        imageContainerView.layer.cornerRadius = dimension/2
        imageContainerView.centerY(inView: self)
    }
    
    private func configure(){
        directionsButton.alpha = 0
        locationTitleLabel.text = place?.mkMapItem.name
        
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        
        guard let mapItemLocation = place?.mkMapItem.placemark.location,
              let mapDistance =  place?.location?.distance(from: mapItemLocation) else {
            locationDistanceLabel.text = ""
            return
        }

        let distanceString = distanceFormatter.string(fromDistance:mapDistance)
        locationDistanceLabel.text = distanceString
        
    }
}
