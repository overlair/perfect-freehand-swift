//
//  File.swift
//  perfect-freehand-swift
//
//  Created by John Knowles on 1/27/25.
//

import CoreGraphics


enum FreehandConstant {
    static let RATE_OF_PRESSURE_CHANGE = CGFloat(0.275)
    static let FIXED_PI = CGFloat.pi + 0.00001

}

extension CGPoint {
    /**
     * Negate a vector.
     */
    @inlinable func neg() -> CGPoint {
        CGPoint(x: -self.x,y:  -self.y)
    }

    /**
     * Add vectors.
     */
    @inlinable func add(_ point: CGPoint) -> CGPoint  {
        CGPoint(x: self.x + point.x, y: self.y + point.y)
    }

    /**
     * Subtract vectors.
     */
    @inlinable func sub(_ point: CGPoint) -> CGPoint  {
        CGPoint(x: self.x - point.x, y:  self.y - point.y)
    }

    /**
     * Vector multiplication by scalar
     */
    @inlinable func mul(_ n: CGFloat) -> CGPoint  {
        CGPoint(x: self.x * n, y:  self.y * n)
    }

    /**
     * Vector division by scalar.
     */
    @inlinable func div(_ n: CGFloat)  -> CGPoint {
        CGPoint(x: self.x / n, y: self.y / n)
    }

    /**
     * Perpendicular rotation of a vector A
     */
    @inlinable func per()  -> CGPoint {
      CGPoint(x: self.y,y:  -self.x)
    }

    /**
     * Dot product
     */
    @inlinable func dpr(_ point: CGPoint)  -> CGFloat {
      self.x * point.x + self.y * point.y
    }

    /**
     * Get whether two vectors are equal.
     */
    @inlinable func isEqual(_ point: CGPoint) -> Bool  {
      self.x == point.x && self.y == point.y
    }

    /**
     * Length of the vector
     */
    @inlinable func len()  -> CGFloat {
      hypot(self.x, self.y)
    }

    /**
     * Length of the vector squared
     */
    @inlinable func len2()  -> CGFloat {
        self.x * self.x + self.y * self.y
        
    }

    /**
     * Dist length from A to B squared.
     */
    @inlinable func dist2(_ point: CGPoint) -> CGFloat  {
        self.sub(point).len2()
    }

    /**
     * Get normalized / unit vector.
     */
    @inlinable func uni() -> CGPoint  {
        self.div(self.len())
    }

    /**
     * Dist length from A to B
     */
    @inlinable func dist(_ point: CGPoint)  -> CGFloat {
      return hypot(self.y - point.y, self.x - point.x)
    }

    /**
     * Mean between two vectors or mid vector between two vectors
     */
    @inlinable func med(_ point: CGPoint)  -> CGPoint {
        self.add(point).mul(0.5)
    }

    /**
     * Rotate a vector around another vector by r (radians)
     */
    @inlinable func rotAround(_ point: CGPoint, r: CGFloat)  -> CGPoint  {
        let s = sin(r)
        let c = cos(r)

        let px = self.x - point.x
        let py = self.y - point.y

        let nx = px * c - py * s
        let ny = px * s + py * c

        return CGPoint(x: nx + point.x,
                      y: ny + point.y)
    }

    /**
     * Interpolate vector A to B with a scalar t
     */
    @inlinable func lrp(_ point: CGPoint, t: CGFloat)  -> CGPoint {
        self.add(point.sub(self).mul(t))
    }

    /**
        Project a point A in the direction B by a scalar c
     */
    @inlinable func prj(_ point: CGPoint, c: CGFloat)  -> CGPoint {
        self.add(point.mul(c))
    }

}
