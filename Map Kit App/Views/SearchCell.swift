//
//  SearchCell.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit

class SearchCell: UITableViewCell {
    // MARK: - Properties
    static let cellIdentifier = "SearchCell"
    
    // MARK: - Lifecycles
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
}
