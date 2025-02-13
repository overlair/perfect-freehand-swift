//
//  File.swift
//  perfect-freehand-swift
//
//  Created by John Knowles on 1/27/25.
// (Comments lifted from https://github.com/steveruizok/perfect-freehand)

import CoreGraphics


extension [FreehandPoint] {
    
    public func getPath(options: FreehandOptions = FreehandOptions()) -> CGPath {
        let path = CGMutablePath()
        let points = getStroke(points: self, options: options)
        
        if (points.count < 4) {
          return path
        }

        var a = points[0]
        var b = points[1]
        let c = points[2]
        
        path.move(to: a)
        path.addQuadCurve(to: CGPoint(x: (b.x + c.x) / 2,
                                      y: (b.y + c.y) / 2),
                          control: b)
        
        for i in 2..<points.count - 1 {
              a = points[i]
              b = points[i + 1]
            
            path.addQuadCurve(to: CGPoint(x: (a.x + b.x) / 2,
                                          y: (a.y + b.y) / 2),
                              control: a)
            
        }
        
        path.closeSubpath()
        
        return path
       
    }
    
    private func getStroke(
      points: [FreehandPoint],
      options: FreehandOptions
    ) -> [CGPoint] {
        return getStrokeOutlinePoints(points: getStrokePoints(points: points,
                                                              options: options),
                                      options: options)
    }

    
    private func getStrokeOutlinePoints(
        points: [FreehandStrokePoint],
        options: FreehandOptions) -> [CGPoint] {
          
            // We can't do anything with an empty array or a stroke with negative size.
            guard !points.isEmpty, options.size > 0 else {
                return []
            }

             // The total length of the line
            let totalLength = points[points.count - 1].runningLength

            let taperStart = options.start.taper ?? 0
            let taperEnd = options.end.taper ?? 0
            
             // The minimum allowed distance between points (squared)
            let minDistance = pow(options.size * options.smoothing, 2)

             // Our collected left and right points
            var leftPts =  [CGPoint]()
             var rightPts =  [CGPoint]()

             // Previous pressure (start with average of first five pressures,
             // in order to prevent fat starts for every line. Drawn lines
             // almost always start slow!
            
            let cappedCount = Swift.min(points.count, 10)
            var prevPressure = points[0..<cappedCount].reduce(points[0].pressure) { r, e in
                var pressure = e.pressure
                if (options.simulatePressure) {
                     // Speed of change - how fast should the the pressure changing?
                    let sp = Swift.min(1, e.distance / options.size)
                     // Rate of change - how much of a change is there?
                    let rp = Swift.min(1, 1 - sp)
                     // Accelerate the pressure
                    pressure = Swift.min(1, r + (rp - r) * (sp * FreehandConstant.RATE_OF_PRESSURE_CHANGE))

                }
                return (r + pressure) / 2
            }

            // The current radius
             var radius = getStrokeRadius(
                size: options.size,
                thinning: options.thinning,
                pressure: points[points.count - 1].pressure,
                easing: options.easing
                // easig: ///
             )

             // The radius of the first saved point
            var firstRadius = CGFloat?.none

             // Previous vector
             var prevVector = points[0].vector

             // Previous left and right points
             var pl = points[0].point
             var pr = pl

             // Temporary left and right points
             var tl = pl
             var tr = pr

             // Keep track of whether the previous point is a sharp corner
             // ... so that we don't detect the same corner twice
             var isPrevPointSharpCorner = false

            ///  unused...remove?
//              var short = true

             /*
               Find the outline's left and right points

               Iterating through the points and populate the rightPts and leftPts arrays,
               skipping the first and last pointsm, which will get caps later on.
             */
            let lastIndex = points.count - 1

            for i in 0...lastIndex {
                let point  = points[i].point
                let vector  = points[i].vector
                let distance  = points[i].distance
                let runningLength  = points[i].runningLength
                var pressure  = points[i].pressure

               // Removes noise from the end of the line
               if i < lastIndex && totalLength - runningLength < 3 {
                 continue
               }

               /*
                 Calculate the radius

                 If not thinning, the current point's radius will be half the size; or
                 otherwise, the size will be based on the current (real or simulated)
                 pressure.
               */

                if options.thinning > 0 {
                    if options.simulatePressure {
                   // If we're simulating pressure, then do so based on the distance
                       // between the current point and the previous point, and the size
                       // of the stroke. Otherwise, use the input pressure.
                        let sp = Swift.min(1, distance / options.size)
                        let rp = Swift.min(1, 1 - sp)
                        pressure = Swift.min(
                         1,
                         prevPressure + (rp - prevPressure) * (sp * FreehandConstant.RATE_OF_PRESSURE_CHANGE)
                       )
                     }

                    radius = getStrokeRadius(size: options.size,
                                             thinning: options.thinning,
                                             pressure: pressure,
                                             easing: options.easing)
               } else {
                   radius = options.size / 2
               }

               if firstRadius == nil {
                 firstRadius = radius
               }

               /*
                 Apply tapering

                 If the current length is within the taper distance at either the
                 start or the end, calculate the taper strengths. Apply the smaller
                 of the two taper strengths to the radius.
               */

                let ts =
                 runningLength < taperStart
                ? options.start.easing(runningLength / taperStart)
                   : 1

                let te =
                 totalLength - runningLength < taperEnd
                   ? options.end.easing((totalLength - runningLength) / taperEnd)
                   : 1

                radius = Swift.max(0.01, radius * Swift.min(ts, te))

               /* Add points to left and right */

               /*
                 Handle sharp corners

                 Find the difference (dot product) between the current and next vector.
                 If the next vector is at more than a right angle to the current vector,
                 draw a cap at the current point.
               */

               let nextVector = (i < lastIndex ? points[i + 1] : points[i])
                 .vector
                let nextDpr = i < lastIndex ? vector.dpr(nextVector) : 1.0
                let prevDpr = vector.dpr(prevVector)

                let isPointSharpCorner = prevDpr < 0 && !isPrevPointSharpCorner
                let isNextPointSharpCorner = nextDpr < 0

               if isPointSharpCorner || isNextPointSharpCorner {
                 // It's a sharp corner. Draw a rounded cap and move on to the next point
                 // Considering saving these and drawing them later? So that we can avoid
                 // crossing future points.

                   let offset = prevVector.per().mul(radius)
                   for t in stride(from: 0, to: 1, by: CGFloat(1) / CGFloat(13)) {
                       tl = point.sub(offset).rotAround( point, r: FreehandConstant.FIXED_PI * CGFloat(t))
                       leftPts.append(tl)

                       tr = point.add(offset).rotAround( point, r: FreehandConstant.FIXED_PI * -CGFloat(t))
                       rightPts.append(tr)
                 }

                 pl = tl
                 pr = tr

                 if isNextPointSharpCorner {
                   isPrevPointSharpCorner = true
                 }
                 continue
               }

               isPrevPointSharpCorner = false

               // Handle the last point
               if (i == points.count - 1) {
                   let offset = vector.per().mul(radius)
                   leftPts.append(point.sub(offset))
                   rightPts.append(point.add(offset))
                   continue
               }

               /*
                 Add regular points

                 Project points to either side of the current point, using the
                 calculated size as a distance. If a point's distance to the
                 previous point on that side greater than the minimum distance
                 (or if the corner is kinda sharp), add the points to the side's
                 points array.
               */

                let offset = nextVector.lrp(vector, t: nextDpr).per().mul( radius)

                tl = point.sub(offset)

                if i <= 1 || pl.dist2(tl) > minDistance {
                    leftPts.append(tl)
                    pl = tl
               }

                tr = point.add(offset)

                if i <= 1 || pr.dist2( tr) > minDistance {
                    rightPts.append(tr)
                    pr = tr
               }

               // Set variables for next iteration
               prevPressure = pressure
               prevVector = vector
             }

             /*
               Drawing caps
               
               Now that we have our points on either side of the line, we need to
               draw caps at the start and end. Tapered lines don't have caps, but
               may have dots for very short lines.
             */

             let firstPoint = points[0].point

             let lastPoint =
               points.count > 1
                 ? points[lastIndex].point
                 : points[0].point.add(.init(x: 1, y: 1))

             var startCap =  [CGPoint]()
             var endCap =  [CGPoint]()

             /*
               Draw a dot for very short or completed strokes
               
               If the line is too short to gather left or right points and if the line is
               not tapered on either side, draw a dot. If the line is tapered, then only
               draw a dot if the line is both very short and complete. If we draw a dot,
               we can just return those points.
             */

             if (points.count == 1) {
               if !(taperStart == 0 || taperEnd == 0) || options.last {
                   let start = firstPoint.prj(firstPoint.sub( lastPoint).per().uni(),
                                   c: -(firstRadius ?? radius)
                 )
               
                   var dotPts =  [CGPoint]()
               for t in stride(from: 0, to: 1, by: CGFloat(1) / CGFloat(13)) {
                   dotPts.append(start.rotAround(firstPoint, r: FreehandConstant.FIXED_PI * 2 * CGFloat(t)))
               }
                   
                 return dotPts
               }
             } else {
               /*
               Draw a start cap

               Unless the line has a tapered start, or unless the line has a tapered end
               and the line is very short, draw a start cap around the first point. Use
               the distance between the second left and right point for the cap's radius.
               Finally remove the first left and right points. :psyduck:
             */
    //
               if (taperStart > 0 || (taperEnd > 0 && points.count == 1)) {
                 // The start point is tapered, noop
               } else if (options.start.cap) {
                 // Draw the round cap - add thirteen points rotating the right point around the start point to the left point
                   for t in stride(from: 0, to: 1, by: CGFloat(1) / CGFloat(13)) {
                       let pt = rightPts[0].rotAround(firstPoint, r: FreehandConstant.FIXED_PI * CGFloat(t))
                       startCap.append(pt)
                 }
               } else {
                 // Draw the flat cap - add a point to the left and right of the start point
                   let cornersVector = leftPts[0].sub( rightPts[0])
                   let offsetA = cornersVector.mul( 0.5)
                   let offsetB = cornersVector.mul(0.51)

                   startCap.append(contentsOf: [
                    firstPoint.sub(offsetA),
                    firstPoint.sub(offsetB),
                    firstPoint.add(offsetB),
                    firstPoint.add(offsetA)
                    ]
                 )
               }

               /*
               Draw an end cap

               If the line does not have a tapered end, and unless the line has a tapered
               start and the line is very short, draw a cap around the last point. Finally,
               remove the last left and right points. Otherwise, add the last point. Note
               that This cap is a full-turn-and-a-half: this prevents incorrect caps on
               sharp end turns.
             */

                 let direction = points[lastIndex].vector.neg().per()

               if (taperEnd > 0 || (taperStart > 0 && points.count == 1)) {
                 // Tapered end - push the last point to the line
                 endCap.append(lastPoint)
               } else if options.end.cap {
                 // Draw the round end cap
                   let start = lastPoint.prj(direction, c: radius)
                   for t in stride(from: 0, to: 1, by: CGFloat(1) / CGFloat(29)) {
                       endCap.append(start.rotAround(lastPoint, r:  FreehandConstant.FIXED_PI * 3 * CGFloat(t)))
                   }
                } else {
                 // Draw the flat end cap

                    endCap.append(contentsOf: [
                        lastPoint.add(direction.mul(radius)),
                        lastPoint.add(direction.mul( radius * 0.99)),
                        lastPoint.sub( direction.mul(radius * 0.99)),
                        lastPoint.sub( direction.mul(radius))
                   ]
                 )
               }
             }

             /*
               Return the points in the correct winding order: begin on the left side, then
               continue around the end cap, then come back along the right side, and finally
               complete the start cap.
             */

             return leftPts + endCap + rightPts.reversed() + startCap
    }


    private func getStrokePoints(
        points: [FreehandPoint],
       options: FreehandOptions) -> [FreehandStrokePoint] {

           // If we don't have any points, return an empty  array.
           guard !points.isEmpty else {
               return []
           }
           
           let isComplete = false
           let  size = CGFloat(16)
        
                // Find the interpolation level between points.
           let t =  0.15 + (1 - options.streamline) * 0.85

           // Whatever the input is, make sure that the points are in number[][].
    //       var pts: [[CGFloat]] = points.map { [$0.point.x, $0.point.y, $0.pressure ?? 0.5] }

           var pts = points
          // Add extra points between the two, to help avoid "dash" lines
          // for strokes with tapered start and ends. Don't mutate the
          // input array!
          if (pts.count == 2) {
            let last = pts[1]
    //        pts = pts.slice(0, -1)
              for i in 1..<5 {
                  let point = pts[0].point.lrp(last.point, t: CGFloat(i) / 4)
                  pts.append(.init(point: point, pressure: last.pressure))
            }
          }

          // If there's only one point, add another point at a 1pt offset.
          // Don't mutate the input array!
          if (pts.count == 1) {
              let first = pts[0]
              pts.append(.init(point: first.point.applying(.init(translationX: 1, y: 1)), pressure: first.pressure))

    //        pts = [...pts, [...add(pts[0], [1, 1]), ...pts[0].slice(2)]]
          }

           // The strokePoints array will hold the points for the stroke.
           // Start it out with the first point, which needs no adjustment.

           var strokePoints: [FreehandStrokePoint] = [
            FreehandStrokePoint(point: pts[0].point,
                                pressure:  Swift.min(pts[0].pressure ?? 0.25, 0.25),
                                distance:  0,
                                vector: CGPoint(x: 1, y: 1),
                                runningLength: 0)
           ]

          // A flag to see whether we've already reached out minimum length
          var hasReachedMinimumLength = false

          // We use the runningLength to keep track of the total distance
          var runningLength = CGFloat(0)

          // We're set this to the latest point, so we can use it to calculate
          // the distance and vector of the next point.
          var prev = strokePoints[0]

           let max = pts.count - 1

          // Iterate through all of the points, creating StrokePoints.
           for i in 1..<pts.count {
               
               let point = isComplete &&  i == max ?
                       // If we're at the last point, and `options.last` is true,
                         // then add the actual input point.
               pts[i].point
                   : // Otherwise, using the t calculated from the streamline
                     // option, interpolate a new point between the previous
                     // point the current point.
               prev.point.lrp(pts[i].point, t: t)
           
        
            // If the new point is the same as the previous point, skip ahead.
               if (prev.point.isEqual(point)) { continue }

            // How far is the new point from the previous point?
               let distance = point.dist(prev.point)

            // Add this distance to the total "running length" of the line.
               runningLength += distance

            // At the start of the line, we wait until the new point is a
            // certain distance away from the original point, to avoid noise
            if (i < max && !hasReachedMinimumLength) {
                if (runningLength < size) { continue }
              hasReachedMinimumLength = true
              // TODO: Backfill the missing points so that tapering works correctly.
            }
            // Create a new strokepoint (it will be the new "previous" one).
               prev = .init(
              // The adjusted point
                point: point,
              // The input pressure (or .5 if not specified)
                pressure:  Swift.min(pts[i].pressure ?? 0.5, 0.5),
                // The distance between the current point and the previous point
                distance: distance,
              // The vector from the current point to the previous point
                vector: prev.point.sub(point).uni(),
              // The total distance so far
              runningLength: runningLength
            )

            // Push it to the strokePoints array.
            strokePoints.append(prev)
          }

          // Set the vector of the first point to be the same as the second point.
           strokePoints[0].vector = strokePoints[1].vector

      return strokePoints
    }

    private func getStrokeRadius(
     size: CGFloat,
     thinning: CGFloat,
     pressure: CGFloat,
     easing: @escaping (CGFloat) -> (CGFloat) = { t in  t }
    ) -> CGFloat {
     return size * easing(0.5 - thinning * (0.5 - pressure))
    }

    
}
