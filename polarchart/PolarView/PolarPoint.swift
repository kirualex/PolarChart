//
//  PolarPoint.swift
//  polarchart
//
//  Created by Alexis Creuzot on 05/10/2016.
//  Copyright © 2016 monoqle. All rights reserved.
//

import UIKit

public class PolarPoint: NSObject {
    public var level: UInt = 0
    public var ray: UInt = 0
    public var path = UIBezierPath()

    public init(level: UInt, ray:UInt) {
        self.level = level
        self.ray = ray
    }

    func intersectionCoordinateFor(polarView: PolarView) -> CGPoint {

        var curRadius = CGFloat(level)/CGFloat(polarView.nbLevels) * polarView.radius

        switch polarView.curveType {
        case .rounded(let roundness) :
            curRadius = CGFloat(level)/CGFloat(polarView.nbLevels) * polarView.radius - CGFloat(roundness)/2
            break
        default:
            break
        }

        let ratio = CGFloat(ray)/CGFloat(polarView.nbRays)
        var angle = 2 * CGFloat.pi * ratio
        angle -= CGFloat.pi/2

        let x = polarView.realCenter.x + curRadius * cos(angle)
        let y = polarView.realCenter.y + curRadius * sin(angle)

        return CGPoint(x: x, y: y)
    }

    public func isValidFor(polarView: PolarView) -> Bool{
        return self.level <= polarView.nbLevels && self.ray <= polarView.nbRays
    }
}
