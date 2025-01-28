//
//  File 2.swift
//  perfect-freehand-swift
//
//  Created by John Knowles on 1/27/25.
//

import CoreGraphics

public struct FreehandOptions {
    var size: CGFloat = 40
    var thinning: CGFloat = 0.5
    var smoothing: CGFloat = 0.5
    var streamline: CGFloat = 0.5
    var simulatePressure: Bool = false
    var last: Bool = false

    var easing: (CGFloat) -> (CGFloat) = { t in t }
    var start = FreehandStrokeEnd(easing: { t in t * (2 - t)  })
    var end = FreehandStrokeEnd(easing: { t in (t - 1) * t * (t + 1)  })
    
    public init(size: CGFloat  = 30,
                thinning: CGFloat = 0.5,
                smoothing: CGFloat = 0.5,
                streamline: CGFloat = 0.5,
                simulatePressure: Bool = false,
                last: Bool = false,
                easing: @escaping (CGFloat) -> CGFloat = { t in t },
                start: FreehandStrokeEnd = FreehandStrokeEnd(easing: { t in t * (2 - t)  }),
                end: FreehandStrokeEnd = FreehandStrokeEnd(easing: { t in (t - 1) * t * (t + 1)  })) {
        self.size = size
        self.thinning = thinning
        self.smoothing = smoothing
        self.streamline = streamline
        self.simulatePressure = simulatePressure
        self.last = last
        self.easing = easing
        self.start = start
        self.end = end
    }
}
