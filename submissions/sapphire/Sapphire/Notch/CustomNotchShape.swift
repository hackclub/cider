//
//  CustomNotchShape.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-05-12.
//

import SwiftUI

struct CustomNotchShape: Shape {
    var cornerRadius: CGFloat

    
    var animatableData: CGFloat {
        get { cornerRadius }
        set { cornerRadius = newValue }
    }

    
    
    func path(in rect: CGRect) -> Path {
        
        
        let radii = Self.calculateRadii(cornerRadius: cornerRadius, in: rect)
        let topRadius = radii.top
        let safeBottomRadius = radii.bottom

        
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topRadius, y: rect.minY + topRadius), control: CGPoint(x: rect.minX + topRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + topRadius, y: rect.maxY - safeBottomRadius))
        if safeBottomRadius > 0 { path.addArc(center: CGPoint(x: rect.minX + topRadius + safeBottomRadius, y: rect.maxY - safeBottomRadius), radius: safeBottomRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true) } else { path.addLine(to: CGPoint(x: rect.minX + topRadius, y: rect.maxY)) }
        path.addLine(to: CGPoint(x: rect.maxX - topRadius - safeBottomRadius, y: rect.maxY))
        if safeBottomRadius > 0 { path.addArc(center: CGPoint(x: rect.maxX - topRadius - safeBottomRadius, y: rect.maxY - safeBottomRadius), radius: safeBottomRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: true) } else { path.addLine(to: CGPoint(x: rect.maxX - topRadius, y: rect.maxY)) }
        path.addLine(to: CGPoint(x: rect.maxX - topRadius, y: rect.minY + topRadius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.maxX - topRadius, y: rect.minY))
        path.closeSubpath()
        return path
    }

    
    
    
    
    
    
    
    
    static func calculateRadii(cornerRadius: CGFloat, in rect: CGRect) -> (top: CGFloat, bottom: CGFloat) {
        
        let derivedTopRadiusBase = cornerRadius > 15 ? cornerRadius - 5 : 5
        let maxPossibleTopRadiusFromHeight = rect.height > 0 ? rect.height / 2.0 : 0
        let derivedTopRadius = min(derivedTopRadiusBase, maxPossibleTopRadiusFromHeight)
        let topRadius = max(0.0, min(derivedTopRadius, rect.width / 2.0))

        
        let availableWidthForBottomRadii = rect.width - 2 * topRadius
        let availableHeightForBottomRadius = rect.height - topRadius
        let safeBottomRadius = max(0.0, min(cornerRadius, availableWidthForBottomRadii / 2.0, availableHeightForBottomRadius))

        return (top: topRadius, bottom: safeBottomRadius)
    }
}
