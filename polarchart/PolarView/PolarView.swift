//
//  PolarView.swift
//  polarchart
//
//  Created by Alexis Creuzot on 04/10/2016.
//  Copyright © 2016 monoqle. All rights reserved.
//

import UIKit
import ios_curve_interpolation

public enum CurveType {
    case catmull_Rom(tanMagnitude: Float)
    case hermite
    case rounded(roundness: Float)
}

public enum TouchMode {
    case Modify
    case Inspect
}

public class PolarView: UIView {

    public var touchMode: TouchMode = .Inspect
    public var nbLevels: UInt = 4
    public var nbRays: UInt = 6
    public var circleColor = UIColor.black
    public var rayColor = UIColor.black
    public var pointColor = UIColor.red
    public var inspectPointColor = UIColor.blue
    public var inspectPointRadius: CGFloat = 5
    public var curveType: CurveType = .rounded(roundness: 0)

    public var polarPoints = [PolarPoint]()
    public var polarForms = [PolarForm]()
    public var inspectPoint: PolarPoint?

    private var circles = [UIBezierPath]()
    private var rays = [UIBezierPath]()

    private var diameter: CGFloat = 0
    private(set) var radius: CGFloat = 0
    private(set) var realCenter = CGPoint(x:0, y:0)

    private var formLayer = RadialGradientLayer()
    private var formLayerMask = CAShapeLayer()
    private var inspectPointLayer = CAGradientLayer()
    private var inspectPointLayerMask = CAShapeLayer()
    private var pointsLayer = CAGradientLayer()
    private var pointsLayerMask = CAShapeLayer()
    private var animating = false
    private var selectedRay: UInt?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.addSublayer(formLayer)
        formLayer.mask = formLayerMask
        self.layer.addSublayer(inspectPointLayer)
        inspectPointLayer.mask = inspectPointLayerMask
        self.layer.addSublayer(pointsLayer)
        pointsLayer.mask = pointsLayerMask
    }

    // MARK - Layout

    override public func layoutSubviews() {
        self.refresh()
    }

    public func refresh() {

        diameter = min(self.frame.width, self.frame.height) - 10
        radius = diameter/2
        realCenter = CGPoint(x:self.frame.width/2, y:self.frame.height/2)

        // Circles
        circles.removeAll()
        for i in 1...nbLevels {
            let curRadius = CGFloat(i)/CGFloat(nbLevels) * radius
            let circle = UIBezierPath.init(arcCenter: self.realCenter,
                                           radius: curRadius,
                                           startAngle: 0,
                                           endAngle: 2 * CGFloat.pi,
                                           clockwise: true)

//            self.dottedStrokeFor(path: circle, dotSize: 1, dotSpacing: 3)

            circles.append(circle)
        }

        // Rays
        rays.removeAll()
        for i in 1...nbRays {
            let ratio = CGFloat(i)/CGFloat(nbRays)
            var angle = 2 * CGFloat.pi * ratio
            angle -= CGFloat.pi/2

            let ray = UIBezierPath()
            ray.move(to: self.realCenter)
            let x = self.realCenter.x + radius * cos(angle)
            let y = self.realCenter.y + radius * sin(angle)
            ray.addLine(to: CGPoint(x: x, y: y))
            ray.close()

//            self.dottedStrokeFor(path: ray, dotSize: 1, dotSpacing: 3)

            rays.append(ray)
        }

        // PolarPoints
        for p in polarPoints where p.isValidFor(polarView: self) {
            let intersectPoint = p.intersectionCoordinateFor(polarView: self)
            let pointPath = UIBezierPath.init(arcCenter: intersectPoint,
                                              radius: 4,
                                              startAngle: 0,
                                              endAngle: 2 * CGFloat.pi,
                                              clockwise: true)
            p.path = pointPath
        }

        // PolarForms
        for form in polarForms where form.isValidFor(polarView: self){

            let startPath = formLayerMask.path
            formLayerMask.lineWidth = 0
            var formPath = UIBezierPath()

            // get points as nsvalues
            let pointValues = form.polarPoints.map { (p:PolarPoint) -> NSValue in
                let cgp = p.intersectionCoordinateFor(polarView: self)
                return NSValue(cgPoint: cgp)
            }
            switch self.curveType {
            case .catmull_Rom(let tanMagnitude):
                formPath = UIBezierPath.interpolateCGPoints(withCatmullRom: pointValues, closed: true, alpha: tanMagnitude)
                break
            case .hermite :
                formPath = UIBezierPath.interpolateCGPoints(withHermite: pointValues, closed: true)
                break
            case .rounded(let roundness) :
                formLayerMask.lineWidth = CGFloat(roundness)
                let firstPoint = form.polarPoints.first!
                formPath.move(to: firstPoint.intersectionCoordinateFor(polarView: self))
                for p in form.polarPoints {
                    formPath.addLine(to: p.intersectionCoordinateFor(polarView: self))
                }
                formPath.close()
                break
            }

            // Forms
            formLayer.frame = self.bounds
            formLayer.colors = form.colors.map {$0.cgColor}
            formLayerMask.path = formPath.cgPath
            formLayer.setNeedsDisplay()

            // Forms animation
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.animating = false
            })
            animating = true
            let anim = CABasicAnimation(keyPath: "path")
            anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            anim.duration = 0.25
            anim.fromValue = startPath
            anim.isAdditive = true
            anim.toValue = formLayerMask.path
            anim.isRemovedOnCompletion = true
            formLayerMask.add(anim, forKey: "pathAnim")

            // Inspect point
            if let ip = self.inspectPoint {
                inspectPointLayer.frame = self.bounds
                inspectPointLayer.backgroundColor = self.inspectPointColor.cgColor
                inspectPointLayerMask.path = UIBezierPath.init(arcCenter: ip.intersectionCoordinateFor(polarView: self),
                                                         radius: self.inspectPointRadius,
                                                         startAngle: 0,
                                                         endAngle: 2 * CGFloat.pi,
                                                         clockwise: true).cgPath
            }else {
                inspectPointLayer.frame = CGRect(x: 0,y: 0, width: 0, height: 0)
            }

            // Points
            pointsLayer.frame = self.bounds
            pointsLayer.backgroundColor = self.pointColor.cgColor
            let pointsPath = UIBezierPath()
            for pp in self.polarPoints {
                pointsPath.append(pp.path)
            }
            pointsLayerMask.path = pointsPath.cgPath

            CATransaction.commit()
        }

        self.setNeedsDisplay()
    }

    // MARK - Helpers

    func dottedStrokeFor(path: UIBezierPath, dotSize: CGFloat, dotSpacing: CGFloat) {
        path.lineWidth = dotSize
        let dashes: [CGFloat] = [path.lineWidth * 0, path.lineWidth * dotSpacing]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        path.lineCapStyle = .round
    }

    // MARK - Draw

    override public func draw(_ rect: CGRect) {
        // Circles
        circleColor.setStroke()
        for path in self.circles {
            path.stroke()
        }

        // Rays
        rayColor.setStroke()
        for path in self.rays {
            path.stroke()
        }
    }

    // MARK - Touch

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let t = touch {
            switch self.touchMode {
            case .Modify:
                self.updateFromTouchAt(point: t.location(in: self))
                break
            case .Inspect:
                self.highlightFromTouchAt(point: t.location(in: self))
                break
            }

        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let t = touch {
            switch self.touchMode {
            case .Modify:
                self.updateFromTouchAt(point: t.location(in: self))
                break
            case .Inspect:
                self.highlightFromTouchAt(point: t.location(in: self))
                break
            }

        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedRay = nil
        self.inspectPoint = nil
        self.refresh()
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedRay = nil
        self.inspectPoint = nil
        self.refresh()
    }

    func updateFromTouchAt(point: CGPoint) {

        let polarp = point.toPolarPointFor(polarView: self)

        // Prevent ray switching
        if let ray = selectedRay {
            polarp.ray = ray
        } else {
            selectedRay = polarp.ray
        }

        // Update form
        if let form = self.polarForms.first {
            for p in form.polarPoints {
                if  polarp.ray == p.ray &&
                    polarp.level != p.level {
                    p.level = polarp.level
                    self.refresh()
                    return
                }
            }
        }
    }

    func highlightFromTouchAt(point: CGPoint) {
        let polarp = point.toPolarPointFor(polarView: self)

        // Highlight point on form
        if let form = self.polarForms.first {
            for p in form.polarPoints {
                if  polarp.ray == p.ray {
                    polarp.level = p.level
                    self.inspectPoint = polarp
                    self.refresh()
                    return
                }
            }
        }
    }
}
