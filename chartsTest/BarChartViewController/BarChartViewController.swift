import Charts
import UIKit

class BarChartViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var barChartView: HorizontalBarChartView!

    var inProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupChart()
        updateChartData()
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateChartData()
            }
        }
    }
    
    func setupChart() {
        barChartView.delegate = self
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.fitBars = true
        
        barChartView.maxVisibleCount = 60
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.drawAxisLineEnabled = true
        xAxis.labelCount = 7
        xAxis.labelTextColor = .clear
        
        let leftAxis = barChartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 16, weight: .bold)
        leftAxis.labelCount = 8
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelTextColor = .white
        
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        let rightAxis = barChartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelTextColor = .clear
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.drawAxisLineEnabled = true
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        let l = barChartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.xEntrySpace = 0
        l.yEntrySpace = 0
        l.yOffset = 0
        l.form = .square
        
    }
    
    func updateChartData() {
        self.setDataCount(10, range: 500)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        if self.inProgress {
            return
        }
        
        let start = 1
        
        var yVals = (start..<start+count).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            if arc4random_uniform(100) < 25 {
                return BarChartDataEntry(x: Double(i), y: val, icon: UIImage(named: "icon"))
            } else {
                return BarChartDataEntry(x: Double(i), y: val)
            }
        }
        
        yVals.sort { (entry1: BarChartDataEntry, entry2: BarChartDataEntry) -> Bool in
            return entry1.y < entry2.y
        }
        
        var set1: BarChartDataSet! = nil
        if let set = barChartView.data?.dataSets.first as? BarChartDataSet {
            self.inProgress = true
            let oldDataSet = set
            // new entries is yVals
            let newDataSet = BarChartDataSet(entries: yVals)
            
            var phase: Double = 0.0
                        
            Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if phase > 1.0 {
                    print("done invalidating timer")
                    self.inProgress = false
                    timer.invalidate()
                    return
                }
                let combinedDataSet = self.barChartView.partialResults(setA: oldDataSet,
                                                                       setB: newDataSet,
                                                                       phase: phase)
                combinedDataSet.colors = ChartColorTemplates.material()
                
                let newData = BarChartData(dataSet: combinedDataSet)
                newData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                newData.barWidth = 0.9
                
                self.barChartView.data = newData
                self.barChartView.notifyDataSetChanged()
                
                phase += 0.01
            }
            
        } else {
            set1 = BarChartDataSet(entries: yVals, label: "The year 2017")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            barChartView.data = data
        }
    }
}

extension BarChartView {
// Copied from DanielGindi's reply:
//
//    Create a function that takes dataset A, dataset B, and a phase value between 0 and 1.
//    This function will:
//
//    Define a new dataset C
//    Iterate on each value in A, and set C[i] = (B[i] - A[i]) * phase + A[i]
//    Return C as the new dataset
    public func partialResults(setA: BarChartDataSet, setB: BarChartDataSet, phase: Double) -> BarChartDataSet {
        let newSet = BarChartDataSet()
        
        for index in 0..<setA.entries.count {
            let currA = setA.entries[index].y
            let currB = setB.entries[index].y
            
            let newValue = (currB - currA) * phase + currA
            newSet.append(BarChartDataEntry(x: Double(index), y: newValue))
        }
        
        return newSet
    }
}
