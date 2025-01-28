//
//  File.swift
//  perfect-freehand-swift
//
//  Created by John Knowles on 1/27/25.
//

import CoreGraphics

public struct  FreehandStrokePoint: Hashable {
    let point: CGPoint
    let pressure: CGFloat
    let distance: CGFloat
    var vector: CGPoint
    let runningLength: CGFloat
    
    public init(point: CGPoint,
         pressure: CGFloat,
         distance: CGFloat,
         vector: CGPoint,
                runningLength: CGFloat) {
        self.point = point
        self.pressure = pressure
        self.distance = distance
        self.vector = vector
        self.runningLength = runningLength
    }
}
