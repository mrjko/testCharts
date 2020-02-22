//
//  ViewController.swift
//  chartsTest
//
//  Created by Jimmy Ko on 2020-02-09.
//  Copyright © 2020 Jimmy Ko. All rights reserved.
//

import UIKit
import Charts

class DonutChartViewController: UIViewController {
    struct Constants {
        static let total: Int = 3
        static let centerTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    private var viewModel: DonutChartViewModel = DonutChartViewModel()
    var titles: [String] = [
        "port1", "port2", "To-MPLS", "To-HQ-A", "To-HQ-B"
    ]

    @IBOutlet weak var pieChart: PieChartView!
    
    var currentlyHighlighted: Int = 0
    var dataEntries: [PieChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupPieChart()
        setupView()
        setupPieChartData()
        self.pieChart.delegate = self
        self.pieChart.animate(xAxisDuration: 0.3, easingOption: .linear)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
//                self.setupPieChartData()
                self.pieChart.highlightValue(x: Double(self.currentlyHighlighted), dataSetIndex: 0)
                self.currentlyHighlighted += 1
                if self.currentlyHighlighted == Constants.total {
                    self.currentlyHighlighted = -1
                }
            }
        }
    }
    
    private func setupView() {
        self.view.addSubview(pieChart)
        
        let l = pieChart.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 0
        l.yEntrySpace = 0
        l.yOffset = 0
        
        pieChart.backgroundColor = UIColor.init(red: 64/255, green: 65/255, blue: 77/255, alpha: 1.0)
        pieChart.drawHoleEnabled = true
        pieChart.holeColor = UIColor.init(red: 64/255, green: 65/255, blue: 77/255, alpha: 1.0)
        pieChart.holeRadiusPercent = 0.50
        pieChart.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pieChart.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        pieChart.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        pieChart.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }
    
    private func setupPieChart() {
        self.pieChart.isUserInteractionEnabled = false
        self.pieChart.translatesAutoresizingMaskIntoConstraints = false
        self.pieChart.backgroundColor = UIColor.lightGray.withAlphaComponent(0.20)
        self.pieChart.legend.font = UIFont.systemFont(ofSize: 23, weight: .light)
        self.pieChart.legend.textColor = UIColor.white
        self.pieChart.drawEntryLabelsEnabled = false
        self.pieChart.usePercentValuesEnabled = true
    }
    
    private func setupPieChartData() {
        var dataEntries: [PieChartDataEntry] = []
        for index in 0..<Constants.total {
            let random = Int.random(in: 0...100)
            let dataEntry = PieChartDataEntry.init(value: Double(random), label: "\(self.titles[index] ?? "-")")
            dataEntries.append(dataEntry)
            
        }
        
        self.dataEntries = dataEntries
        let set = PieChartDataSet(entries: dataEntries, label: "")
    
        
        set.colors =
        [
            UIColor.red.withAlphaComponent(0.50),
            UIColor.blue.withAlphaComponent(0.50),
            UIColor.green.withAlphaComponent(0.50),
            UIColor.yellow.withAlphaComponent(0.50),
            UIColor.orange.withAlphaComponent(0.50)
        ]
        
        
        let pieChartData = PieChartData(dataSet: set)
        pieChartData.setValueFont(.systemFont(ofSize: 16, weight: .bold))
        pieChartData.setValueTextColor(.white)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.multiplier = 1.0
        
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: numberFormatter))
        
        pieChart.data = pieChartData
        
    }
}

extension DonutChartViewController: ChartViewDelegate {
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        let centerText = "Total:\n\(1337)"
        let attributedCenterText = NSAttributedString(string: centerText, attributes: Constants.centerTextAttributes)
        self.pieChart.centerAttributedText = attributedCenterText
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let color = chartView.data?.dataSets[0].colors[self.currentlyHighlighted]
        guard let set = chartView.data?.dataSets[0] as? PieChartDataSet else {
            return
        }
        
        set.highlightColor = color?.withAlphaComponent(1.00)
        
        let title = self.titles[Int(highlight.x)]
        let value = self.dataEntries[Int(highlight.x)].value
        
        let centerText = "\(title):\n\(value)"
        
        let attributedCenterText = NSAttributedString(string: centerText, attributes: Constants.centerTextAttributes)
        
        
        self.pieChart.centerAttributedText = attributedCenterText
    
        self.pieChart.defaultAnimation()
//        let animator = Animator()
//        animator.updateBlock = {
//            // Usually the phase is a value between 0.0 and 1.0
//            // Multiply it so you get the final phaseShift you want
//            let phaseShift = 10 * animator.phaseX
//
//            let dataSet = chartView.data?.dataSets.first as? PieChartDataSet
//            // Set the selectionShift property to actually change the selection over time
//
//            dataSet?.selectionShift = CGFloat(phaseShift)
//
//            // In order to see the animation, trigger a redraw every time the selectionShift property was changed
//            chartView.setNeedsDisplay()
//        }
//
//        // Start the animation by triggering the animate function with any timing function you like
//        animator.animate(xAxisDuration: 0.3, easingOption: ChartEasingOption.easeInCubic)
    }
}

extension PieChartView {
    
    func defaultAnimation() {
        let animator = Animator()
        animator.updateBlock = {
            // Usually the phase is a value between 0.0 and 1.0
            // Multiply it so you get the final phaseShift you want
            let phaseShift = 10 * animator.phaseX
            
            let dataSet = self.data?.dataSets.first as? PieChartDataSet
            // Set the selectionShift property to actually change the selection over time
            
            dataSet?.selectionShift = CGFloat(phaseShift)
            
            // In order to see the animation, trigger a redraw every time the selectionShift property was changed
            self.setNeedsDisplay()
        }
        
        // Start the animation by triggering the animate function with any timing function you like
        animator.animate(xAxisDuration: 0.3, easingOption: ChartEasingOption.easeInCubic)
    }
}
