//
//  Extension.swift
//  DrawScape
//
//  Created by Drew Paul on 10/14/18.
//  Copyright © 2018 Drew Paul. All rights reserved.
//

import Foundation

public extension Float {
    
    public static func random() -> Float {
        return Float(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(_ min: Float, max: Float) -> Float {
        return Float.random() * (max - min) + min
    }
}

extension Int {
    var degreesToRadians: Double {
        return Double(self) * .pi/180 
    }
}
