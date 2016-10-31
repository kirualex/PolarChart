//
//  PolarForm.swift
//  polarchart
//
//  Created by Alexis Creuzot on 05/10/2016.
//  Copyright © 2016 monoqle. All rights reserved.
//

import UIKit

public class PolarForm: NSObject {
    var polarPoints = [PolarPoint]()
    var color = UIColor.black
    var path = UIBezierPath()

    init(polarPoints: [PolarPoint]) {
        self.polarPoints = polarPoints
    }

    func isValidFor(polarView: PolarView) -> Bool{
        var rayIndexes = Set<UInt>()
        for i in 0...polarView.nbRays-1 {
            rayIndexes.insert(i)
        }
        let pointsRays = Set(self.polarPoints.map { $0.ray })

        // Check that all rays have a point, and all points are valid
        let raysCovered =  rayIndexes.symmetricDifference(pointsRays).count == 0
        let validPoints = self.polarPoints.reduce(true, { (res, polarp) -> Bool in
            return polarp.isValidFor(polarView: polarView) && res
        })

        return raysCovered && validPoints
    }
}
