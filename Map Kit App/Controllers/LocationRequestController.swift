//
//  LocationRequestController.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit

class LocationRequestController:UIViewController {
    // MARK: - Properties
    let mapPinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        return imageView
    }()
    
    let allowLocationLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Allow Location\n\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
        attributedText.append(NSAttributedString(string: "Please enable location services, to track your movments", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let enableLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable Location", for: .normal)
        button.setTitleColor( .white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(enableLocationHandler), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Selectors
    @objc private func enableLocationHandler(){
        print("DEBUG: enable location")
    }
    
    // MARK: - Helpers
    private func setupUI(){
        view.backgroundColor = .white
        setupMapPinImageView()
        setupAllowLocationLabel()
        setupEnableLocationButton()
    }
    
    private func setupEnableLocationButton(){
        view.addSubview(enableLocationButton)
        enableLocationButton.anchor(top: allowLocationLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32, width: 160, height: 50)
    }
    
    private func setupAllowLocationLabel(){
        view.addSubview(allowLocationLabel)
        allowLocationLabel.anchor(top:mapPinImageView.bottomAnchor,left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
    }
    
    private func setupMapPinImageView(){
        view.addSubview(mapPinImageView)
        mapPinImageView.anchor(top:view.topAnchor, paddingTop: 140, width: 200, height: 200)
        mapPinImageView.centerX(inView: view)
    }
}
