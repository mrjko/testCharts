//
//  LineChartViewController.swift
//  chartsTest
//
//  Created by Jimmy Ko on 2020-02-15.
//  Copyright © 2020 Jimmy Ko. All rights reserved.
//
import Charts
import UIKit

class LineChartViewController: UIViewController {
    @IBOutlet weak var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLineChart()
        self.updateChartData()
    
        chartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateChartData()
                self.chartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
            }
        }
    }
    
    func setupLineChart() {
        chartView.delegate = self
        chartView.isUserInteractionEnabled = true
        chartView.chartDescription?.enabled = false
        chartView.backgroundColor = UIColor.init(red: 64/255, green: 65/255, blue: 77/255, alpha: 1.0)
        chartView.highlightPerDragEnabled = true
        chartView.dragEnabled = true
        chartView.legend.enabled = true

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 16, weight: .bold)
        xAxis.labelTextColor = .white
        xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()
        
        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 170
        rightAxis.labelTextColor = .clear
        rightAxis.yOffset = -9
    

        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .bold)
        leftAxis.labelTextColor = .white
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 170
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        
        chartView.rightAxis.enabled = true
        chartView.legend.form = .square
    }
    
    func updateChartData() {
        self.setDataCount(24, range: 30)
    }
    
    func setDataCount(_ hoursOfData: Int, range: UInt32) {
        let now = Date().timeIntervalSinceNow
        let hourSeconds: TimeInterval = 3600
        
        let from = now - (Double(hoursOfData)) * hourSeconds
        let to = now // + (Double(count) / 2) * hourSeconds
        
        let values = stride(from: from, to: to, by: hourSeconds).map { (x) -> ChartDataEntry in
            let y = arc4random_uniform(range) + 50
            return ChartDataEntry(x: x, y: Double(y))
        }
        
        let values2 = stride(from: from, to: to, by: hourSeconds).map { (x) -> ChartDataEntry in
            let y = arc4random_uniform(range) + 50
            return ChartDataEntry(x: x, y: Double(y))
        }
        
        let set1 = LineChartDataSet(entries: values, label: "FTNT-Guest")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.fillAlpha = 0.15
        set1.drawFilledEnabled = true
        set1.circleRadius = 5
        set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = true
        
        let set2 = LineChartDataSet(entries: values2, label: "FTNT-Staff")
        set2.axisDependency = .left
        set2.setColor(.green)
        set2.lineWidth = 1.5
        set2.drawCirclesEnabled = false
        set2.drawValuesEnabled = false
        set2.fillAlpha = 0.15
        set2.drawFilledEnabled = true
        set2.circleRadius = 5
        set2.fillColor = .green
        set2.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set2.drawCircleHoleEnabled = true
        
        let data = LineChartData(dataSets: [set1, set2])
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 15, weight: .bold))
        
        chartView.data = data
    }
}

extension LineChartViewController: ChartViewDelegate {
    
}

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
//        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
