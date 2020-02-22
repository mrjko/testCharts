//
//  ViewController.swift
//  chartsTest
//
//  Created by Jimmy Ko on 2020-02-09.
//  Copyright © 2020 Jimmy Ko. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var topLeft: UIView!
    @IBOutlet weak var topRight: UIView!
    @IBOutlet weak var bottomLeft: UIView!
    @IBOutlet weak var bottomRight: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        let donutChartVC = DonutChartViewController()
        self.embed(donutChartVC, inside: topRight)
        
        let lineTimeChartVC = LineChartViewController()
        self.embed(lineTimeChartVC, inside: topLeft)
        
        let barChartVC = BarChartViewController()
        self.embed(barChartVC, inside: bottomLeft)
    }
}

extension ViewController {
    func embed(_ vc: UIViewController, inside view: UIView) {
        vc.willMove(toParent: self)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
    }
}
