//
//  NotchConfiguration.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-05-08.
//

import SwiftUI

struct NotchConfiguration {
    
    static let universalWidth: CGFloat = 195
    static let universalHeight: CGFloat = 32
    static let initialSize = CGSize(width: universalWidth, height: universalHeight)
    static let initialCornerRadius: CGFloat = 10

    
    static let scaleFactor: CGFloat = 1.12 
    static let hoverExpandedSize = CGSize(width: universalWidth * scaleFactor, height: universalHeight * scaleFactor)
    static let hoverExpandedCornerRadius: CGFloat = 10
    
    static let autoExpandedCornerRadius: CGFloat = 14
    static let autoExpandedTallHeight: CGFloat = 80
        
    static let autoExpandedContentVerticalPadding: CGFloat = 8
    
    static let clickExpandedCornerRadius: CGFloat = 40
    
    
    static let collapseDelay: TimeInterval = 0.07
    
    
    
    static let expandAnimation = Animation.spring(response: 0.45, dampingFraction: 0.625, blendDuration: 0)
    
    
    
    

    
    static let collapseAnimation = Animation.spring(response: 0.35, dampingFraction: 1, blendDuration: 0)
    
    static let autoExpandAnimation = Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)

    
    static let expandedShadowColor = Color.black.opacity(0.4)
    static let expandedShadowRadius: CGFloat = 18
    static let expandedShadowOffset = CGPoint(x: 0, y: 8)
    
    
    static let contentTopPadding: CGFloat = 10
    static let contentBottomPadding: CGFloat = 10
    static let contentHorizontalPadding: CGFloat = 35
    static let contentVisibilityThresholdHeight: CGFloat = universalHeight + 1
}
