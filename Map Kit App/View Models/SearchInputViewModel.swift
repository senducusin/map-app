//
//  SearchInputViewModel.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit

struct ExpansionHeight {
    let collapsed:CGFloat
    let partiallyExpanded: CGFloat
    let fullyExpanded: CGFloat
}

enum ExpansionState: Int,CaseIterable {
    case Collapsed, PartiallyExpanded, FullyExpanded, ExpandToSearch
}

struct SearchInputViewModel {
    
    let viewHeight: CGFloat
    
    var expansionHeight: ExpansionHeight?
    
    private(set) var expansionState: ExpansionState = .Collapsed
    
    mutating func updateState(withGesture direction: UISwipeGestureRecognizer.Direction) -> CGFloat?{
        guard let heightAdjustment = self.expansionHeight else {return nil}
        
        switch expansionState {
        case .Collapsed where direction == .up :
            expansionState = .PartiallyExpanded
            return heightAdjustment.partiallyExpanded
            
        case .PartiallyExpanded where direction == .up:
            expansionState = .FullyExpanded
            return heightAdjustment.fullyExpanded
            
        case .PartiallyExpanded where direction == .down:
            expansionState = .Collapsed
            return heightAdjustment.collapsed
            
        case .FullyExpanded where direction == .down:
            expansionState = .PartiallyExpanded
            return heightAdjustment.partiallyExpanded
            
        case .ExpandToSearch where direction == .down:
            expansionState = .Collapsed
            return heightAdjustment.collapsed
            
        default:break
        }
        
        
        return nil
    }
    
    mutating func updateState(withState state:ExpansionState) -> CGFloat? {
        guard let heightAdjustment = self.expansionHeight else {return nil}
        
        expansionState = (state == .ExpandToSearch) ? .FullyExpanded : state
        
        switch state {
        case .ExpandToSearch:
            return heightAdjustment.fullyExpanded
        
        case .Collapsed:
            return heightAdjustment.collapsed
        default:break
        }
        
        return nil
    }
}

extension SearchInputViewModel {
    init(viewHeight:CGFloat, originY:CGFloat){
        self.viewHeight = viewHeight
        
        let mediumExpansion = viewHeight * 0.27
        let largeExpansion = viewHeight * 0.50
        let maximumExpansion = mediumExpansion + largeExpansion
        
        self.expansionHeight = ExpansionHeight(
            collapsed: originY,
            partiallyExpanded: originY - mediumExpansion,
            fullyExpanded: originY - maximumExpansion
        )
    }
}
