//
//  SearchCellViewModel.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/12/21.
//

import Foundation
import MapKit

struct SearchCelViewModel{
    var mapItem: MKMapItem
    
    var itemName: String {
        return mapItem.name ?? "-"
    }
    
    var itemDistance: String {
       
        
       
        
        return ""
    }
}
