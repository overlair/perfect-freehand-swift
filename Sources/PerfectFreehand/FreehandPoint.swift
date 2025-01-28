//
//  File.swift
//  perfect-freehand-swift
//
//  Created by John Knowles on 1/27/25.
//

import CoreGraphics

public struct FreehandPoint: Hashable {
    let point: CGPoint
    let pressure: CGFloat?
    
    public init(point: CGPoint, pressure: CGFloat?) {
        self.point = point
        self.pressure = pressure
    }
}


