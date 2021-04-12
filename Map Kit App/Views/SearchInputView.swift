//
//  SearchInputView.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit

class SearchInputView: UIView {
    // MARK: - Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 72
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        view.alpha = 0.8
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for a place or address"
        searchBar.barStyle = .default
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var viewModel = SearchInputViewModel(viewHeight: self.frame.height, originY: self.frame.origin.y)
    
    // MARK: - Lifecycles
    override init(frame: CGRect){
        super.init(frame: frame)
        setupUI()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc private func gestureSwipeHandler(sender: UISwipeGestureRecognizer){
        
        if let targetPosition = viewModel.updateState(withGesture: sender.direction) {
            print("DEBUG: \(targetPosition)")
            animateInputView(targetPosition: targetPosition)
            
            if viewModel.expansionState == .Collapsed {
                cancelSearch()
            }
        }
    }
    
    // MARK: - Helpers
    private func animateInputView(targetPosition: CGFloat){
        UIView.animate(withDuration: 0.5,delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.frame.origin.y = targetPosition
        })
    }
    
    private func setupUI(){
        backgroundColor = .white
        
        setupIndicatorView()
        setupSearchBar()
        setupTableView()
        
    }
    
    private func cancelSearch(){
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    private func setupGestureRecognizers(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(gestureSwipeHandler))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(gestureSwipeHandler))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
    }
    
    private func setupIndicatorView(){
        addSubview(indicatorView)
        indicatorView.anchor(top: topAnchor, paddingTop: 8, width: 40, height: 8)
        indicatorView.centerX(inView: self)
    }
    
    private func setupSearchBar(){
        addSubview(searchBar)
        searchBar.anchor(top:indicatorView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingRight: 8, height: 50)
    }
    
    private func setupTableView(){
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 100)
    }
}

extension SearchInputView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.cellIdentifier, for: indexPath) as! SearchCell
        
        return cell
    }
}

extension SearchInputView: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let targetPosition = viewModel.updateState(withState: .ExpandToSearch){
            animateInputView(targetPosition: targetPosition)
            searchBar.showsCancelButton = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let targetPosition = viewModel.updateState(withState: .Collapsed){
            animateInputView(targetPosition: targetPosition)
            cancelSearch()
        }
    }
}
