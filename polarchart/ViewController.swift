//
//  ViewController.swift
//  polarchart
//
//  Created by Alexis Creuzot on 04/10/2016.
//  Copyright © 2016 monoqle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var polarTypeControl: UISegmentedControl!
    @IBOutlet private var polarView: PolarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        polarView.nbLevels = 6
        polarView.nbRays = 12
        polarView.curveType = .hermite
        polarView.circleColor = UIColor.gray
        polarView.rayColor = UIColor.gray
        polarView.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.randomizeForm()
    }

    @IBAction func randomizeForm() {

        var formPoints = [PolarPoint]()
        for i in 0...UInt(polarView.nbRays-1) {
            let randLevel = UInt(arc4random_uniform(UInt32(polarView.nbLevels))+1)
            formPoints.append(PolarPoint(level:randLevel, ray:i))
        }
        let polarForm = PolarForm(polarPoints: formPoints)

        let colors = [UIColor.blue, UIColor.green, UIColor.purple, UIColor.magenta, UIColor.red]
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        let randomIndex2 = Int(arc4random_uniform(UInt32(colors.count)))

        polarForm.colors = [colors[randomIndex].withAlphaComponent(0.8),
                            colors[randomIndex2].withAlphaComponent(0.8)]
        polarView.polarForm = polarForm

        polarView.refresh()
    }

    @IBAction func onTypeChange(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.polarView.touchMode = .Inspect
        default:
            self.polarView.touchMode = .Modify
        }
    }
}

extension ViewController: PolarViewDelegate {

    func polarView(polarView: PolarView, didInspect point: PolarPoint) {
        print("PolarView didInspect \(point)")
    }

    func polarView(polarView: PolarView, didModify previousPoint: PolarPoint, to point: PolarPoint) {
        print("PolarView didModify \(previousPoint) to: \(point)")
    }

}
