//
//  File.swift
//  perfect-freehand-swift
//
//  Created by John Knowles on 1/27/25.
//

import CoreGraphics

public struct FreehandStrokeEnd {
    var cap = true
    var taper: CGFloat? = 0.5
    var easing: (CGFloat) -> (CGFloat) = { t in t }
    
    public init(cap: Bool = true,
         taper: CGFloat? = nil,
         easing: @escaping (CGFloat) -> CGFloat = { t in t }) {
        self.cap = cap
        self.taper = taper
        self.easing = easing
    }
}

extension FreehandStrokeEnd: Hashable {
    public static func == (lhs: FreehandStrokeEnd, rhs: FreehandStrokeEnd) -> Bool {
        lhs.cap == rhs.cap && lhs.taper == rhs.taper
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cap)
        hasher.combine(taper)
    }
}
