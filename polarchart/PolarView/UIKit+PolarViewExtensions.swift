//
//  UIKit+PolarViewExtensions.swift
//  polarchart
//
//  Created by Alexis Creuzot on 05/10/2016.
//  Copyright © 2016 monoqle. All rights reserved.
//

import UIKit

extension CGPoint {
    func distanceTo(p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }

    func toPolarPointFor(polarView: PolarView) -> PolarPoint {

        let distance = polarView.realCenter.distanceTo(p: self)
        var ratio = distance / polarView.radius
        var level = round(ratio*CGFloat(polarView.nbLevels))
        level = max(level, 1)
        level = min(level, CGFloat(polarView.nbLevels))

        let originX = polarView.realCenter.x - self.x
        let originY = polarView.realCenter.y - self.y
        let bearingRadians = CGFloat(atan2f(Float(originY), Float(originX))) - CGFloat.pi/2
        var bearingDegrees = CGFloat(bearingRadians).degrees
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }

        ratio = bearingDegrees / 360
        let ray = round(ratio*CGFloat(polarView.nbRays))

        return PolarPoint(level: UInt(level), ray: UInt(ray))
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / M_PI)
    }
}
