#  PerfectFreehand

Pressure-sensitive freehand drawing, in Swift.

Uses CoreGraphics. 

Port of [Steve Ruiz's](https://github.com/steveruizok) excellent [perfect-freehand](https://github.com/steveruizok/perfect-freehand) library.

## Installation

> Add `https://github.com/overlair/perfect-freehand-swift` in SPM
 
## Usage

```swift
import PerfectFreehand
 
// 1, store FreehandPoint points in array
let points: [FreehandPoint] = ...

// 2, create FreehandOption configuration
let options: FreehandOption = ...

// 3. combine into CGPath
let path: CGPath = points.getPath(options: options)

```
## Demo

https://github.com/user-attachments/assets/a5053b6a-154a-45a7-9aca-17689615ea3c

