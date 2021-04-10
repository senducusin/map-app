//
//  SearchInputViewModel.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/10/21.
//

import UIKit

struct HeightAdjustment {
    let medium: CGFloat
    let maximum: CGFloat
}

struct SearchInputViewModel {
    enum ExpansionState: Int,CaseIterable {
        case NotExpanded, PartiallyExpanded, FullyExpanded, ExpandToSearch
    }
    
    let viewHeight: CGFloat
    var originY: CGFloat
    
    var heightAdjustment: HeightAdjustment?
    
    private(set) var expansionState: ExpansionState = .NotExpanded
    
    mutating func updateState(direction: UISwipeGestureRecognizer.Direction) -> CGFloat?{
        guard let heightAdjustment = self.heightAdjustment else {return nil}
        
      
        print("DEBUG: \(originY)")
        switch expansionState {
            case .NotExpanded where direction == .up :
                self.expansionState = .PartiallyExpanded
                originY = originY - heightAdjustment.medium
                return originY
        
            case .PartiallyExpanded where direction == .up:
                self.expansionState = .FullyExpanded
                originY = originY - heightAdjustment.maximum
                return originY
        
            case .PartiallyExpanded where direction == .down:
                self.expansionState = .NotExpanded
                originY = originY + heightAdjustment.medium
                return originY
                
            case .FullyExpanded where direction == .down:
                self.expansionState = .PartiallyExpanded
                originY = originY + heightAdjustment.maximum
                return originY
                
            case .ExpandToSearch:
                break
                
            default:break
        }
        
        
        return nil
    }
}

extension SearchInputViewModel {
    init(viewHeight:CGFloat, originY:CGFloat){
        self.viewHeight = viewHeight
        
        self.heightAdjustment = HeightAdjustment(medium: viewHeight * 0.27, maximum: viewHeight * 0.50)
        
        print("DEBUG: \(heightAdjustment)")
        self.originY = originY
    }
}
