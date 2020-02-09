//
//  ProgressViewController.swift
//  FocOnApp1
//
//  Created by Eric Stein on 1/14/20.
//  Copyright © 2020 Eric Stein. All rights reserved.
//

import UIKit
import Charts
import CoreData


class ProgressVC: UIViewController {
    
        let dataC = DataController()
        private let formatter = DateFormatter()

    @IBOutlet weak var currentDate: UILabel!
    
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var chartView: BarChartView!
    
    @IBAction func timeSegmentChanged(_ sender: Any) {
     configure()
    }

        var completedGoals = [Double]()
        var totalGoals = [Double]()
    //time segment toggled to months
        let months = ["Jan", "Feb", "Mar", "Apr", "May","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
    //time segment toggled to weeks
        let weeks = ["Week 1","Week 2","Week 3","Week 4","Week 5"]
        
        func configure() {
            chartView.delegate = self as? ChartViewDelegate
            chartView.isUserInteractionEnabled = false
            /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
            chartView.drawBarShadowEnabled = false
            /// if set to true, all values are drawn above their bars, instead of below their top
            chartView.drawValueAboveBarEnabled = false
//            chartView.fitBars = false
            /// The right y-axis object. In the horizontal bar-chart, this is the bottom axis.
            chartView.rightAxis.enabled = false

            if timeSegment.selectedSegmentIndex == 0 {
                let xAxis = chartView.xAxis
                xAxis.drawGridLinesEnabled = false
                xAxis.labelPosition = .bottom
                xAxis.centerAxisLabelsEnabled = true
                xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
                xAxis.granularity = 1
                xAxis.labelCount = 12
                xAxis.centerAxisLabelsEnabled = false
                
                
                let leftAxisFormatter = NumberFormatter()
                leftAxisFormatter.maximumFractionDigits = 1
                
                let yaxis = chartView.leftAxis
                yaxis.spaceTop = 0.35
                yaxis.axisMinimum = 0
                yaxis.drawGridLinesEnabled = false
                setChartForMonths()

            } else {
                let xAxis = chartView.xAxis
                xAxis.drawGridLinesEnabled = false
                xAxis.labelPosition = .bottom
                xAxis.centerAxisLabelsEnabled = true
                xAxis.valueFormatter = IndexAxisValueFormatter(values:weeks)
                xAxis.granularity = 1
                xAxis.labelCount = 4
                
                let leftAxisFormatter = NumberFormatter()
                leftAxisFormatter.maximumFractionDigits = 1
                
                let yaxis = chartView.leftAxis
                yaxis.spaceTop = 0.35
                yaxis.axisMinimum = 0
                yaxis.drawGridLinesEnabled = false
                setChartForWeeks()
            }
        }
    
       //MARK:-Chart for the months
        func setChartForMonths() {
            var dataEntries1 = [BarChartDataEntry]()
            var dataEntries2 = [BarChartDataEntry]()
            let xValuesForTotalGoals = [0.5,1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5,11.5]
            if dataC.allGoalsObjects(achieved: true) != nil || dataC.allGoalsObjects(achieved: false) != nil {
                totalGoals = dataC.monthly(goals: dataC.allGoalsObjects(achieved: false)!)
                completedGoals = dataC.monthly(goals: dataC.allGoalsObjects(achieved: true)!)
                for i in 0..<months.count {
                    dataEntries1.append(BarChartDataEntry(x: xValuesForTotalGoals[i], y: totalGoals[i]))
                    dataEntries2.append(BarChartDataEntry(x: Double(i), y: completedGoals[i]))
                }
            }
            let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Total Number Of Goals")
            chartDataSet1.colors = [UIColor.lightGray]
            chartDataSet1.valueTextColor = UIColor.white
            
            let chartDataSet2 = BarChartDataSet(entries: dataEntries2, label: "Completed Goals")
            chartDataSet2.colors = [UIColor.red]
            chartDataSet2.valueTextColor = UIColor.white
            
            let chartData = BarChartData(dataSets: [chartDataSet1, chartDataSet2])
            let barWidth = 0.5
            chartData.barWidth = barWidth
            chartView.notifyDataSetChanged()
            chartView.data = chartData
            chartView.animate(xAxisDuration: 2, yAxisDuration: 2, easingOption: .linear)
        }
    
        //MARK: -Chart for the weeks
        func setChartForWeeks() {
            var dataEntries1 = [BarChartDataEntry]()
            var dataEntries2 = [BarChartDataEntry]()
            let xValuesForTotalGoals = [0.5,1.5,2.5,3.5,4.5]
            if dataC.allGoalsObjects(achieved: true) != nil || dataC.allGoalsObjects(achieved: false) != nil {
                totalGoals = dataC.weekly(goals: dataC.allGoalsObjects(achieved: false)!)
                completedGoals = dataC.weekly(goals: dataC.allGoalsObjects(achieved: true)!)
                for i in 0..<weeks.count {
                    dataEntries1.append(BarChartDataEntry(x: xValuesForTotalGoals[i], y: totalGoals[i]))
                    dataEntries2.append(BarChartDataEntry(x: Double(i), y: completedGoals[i]))
                }
            }
            
            let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Total Number Of Goals")
            chartDataSet1.colors = [UIColor.lightGray]
            chartDataSet1.valueTextColor = UIColor.white
            
            let chartDataSet2 = BarChartDataSet(entries: dataEntries2, label: "Completed Goals")
            chartDataSet2.colors = [UIColor.red]
            chartDataSet2.valueTextColor = UIColor.white
            
            let chartData = BarChartData(dataSets: [chartDataSet1, chartDataSet2])
            let barWidth = 0.5
            chartData.barWidth = barWidth
            chartView.notifyDataSetChanged()
            chartView.data = chartData
            chartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
        }
        
        func configureDate() {
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            currentDate.text = formatter.string(from: Date())
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            configure()
            configureDate()
 
        }
    }
