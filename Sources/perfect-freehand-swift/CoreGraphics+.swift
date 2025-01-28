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
/**
 * Negate a vector.
 * @param A
 * @internal
 */
func neg(A: CGPoint) -> CGPoint {
    return CGPoint(x: -A.x,y:  -A.y)
}

/**
 * Add vectors.
 * @param A
 * @param B
 * @internal
 */
func add(A: CGPoint, B: CGPoint) -> CGPoint  {
    return CGPoint(x: A.x + B.x, y: A.y + B.y)
}

/**
 * Subtract vectors.
 * @param A
 * @param B
 * @internal
 */
func sub(A: CGPoint, B: CGPoint) -> CGPoint  {
    return CGPoint(x: A.x - B.x, y:  A.y - B.y)
}

/**
 * Vector multiplication by scalar
 * @param A
 * @param n
 * @internal
 */
func mul(A: CGPoint, n: CGFloat) -> CGPoint  {
  return CGPoint(x: A.x * n, y:  A.y * n)
}

/**
 * Vector division by scalar.
 * @param A
 * @param n
 * @internal
 */
func div(A: CGPoint, n: CGFloat)  -> CGPoint {
  return CGPoint(x: A.x / n, y: A.y / n)
}

/**
 * Perpendicular rotation of a vector A
 * @param A
 * @internal
 */
func per(A: CGPoint)  -> CGPoint {
  return CGPoint(x: A.y,y:  -A.x)
}

/**
 * Dot product
 * @param A
 * @param B
 * @internal
 */
func dpr(A: CGPoint, B: CGPoint)  -> CGFloat {
  return A.x * B.x + A.y * B.y
}

/**
 * Get whether two vectors are equal.
 * @param A
 * @param B
 * @internal
 */
func isEqual(A: CGPoint, B: CGPoint) -> Bool  {
  return A.x == B.x && A.y == B.y
}

/**
 * Length of the vector
 * @param A
 * @internal
 */
func len(A: CGPoint)  -> CGFloat {
  return hypot(A.x, A.y)
}

/**
 * Length of the vector squared
 * @param A
 * @internal
 */
func len2(A: CGPoint)  -> CGFloat {
    return A.x * A.x + A.y * A.y
    
}

/**
 * Dist length from A to B squared.
 * @param A
 * @param B
 * @internal
 */
func dist2(A: CGPoint, B: CGPoint) -> CGFloat  {
    return len2(A: sub(A: A, B: B))
}

/**
 * Get normalized / unit vector.
 * @param A
 * @internal
 */
func uni(A: CGPoint) -> CGPoint  {
    return div(A: A, n: len(A: A))
}

/**
 * Dist length from A to B
 * @param A
 * @param B
 * @internal
 */
func dist(A: CGPoint, B: CGPoint)  -> CGFloat {
  return hypot(A.y - B.y, A.x - B.x)
}

/**
 * Mean between two vectors or mid vector between two vectors
 * @param A
 * @param B
 * @internal
 */
func med(A: CGPoint, B: CGPoint)  -> CGPoint {
    return mul(A: add(A: A, B: B), n: 0.5)
}

/**
 * Rotate a vector around another vector by r (radians)
 * @param A vector
 * @param C center
 * @param r rotation in radians
 * @internal
 */
func rotAround(A: CGPoint, C: CGPoint, r: CGFloat)  -> CGPoint  {
  let s = sin(r)
    let c = cos(r)

    let px = A.x - C.x
    let py = A.y - C.y

    let nx = px * c - py * s
    let ny = px * s + py * c

    return CGPoint(x: nx + C.x,
                  y: ny + C.y)
}

/**
 * Interpolate vector A to B with a scalar t
 * @param A
 * @param B
 * @param t scalar
 * @internal
 */
func lrp(A: CGPoint, B: CGPoint, t: CGFloat)  -> CGPoint {
    return add(A: A, B: mul(A: sub(A: B, B: A), n: t))
}

/**
 * Project a point A in the direction B by a scalar c
 * @param A
 * @param B
 * @param c
 * @internal
 */
func prj(A: CGPoint, B: CGPoint, c: CGFloat)  -> CGPoint {
    return add(A: A, B: mul(A: B, n: c))
}

