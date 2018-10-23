//
//  ViewController.swift
//  TestTaskPedometer
//
//  Created by 1 on 12.10.18.
//  Copyright © 2018 Bogdan Magala. All rights reserved.
//

import UIKit
import CoreMotion
import FirebaseFirestore

class PedometerViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!

    var modelController: ModelController!
    
    let calendar = NSCalendar(identifier: .gregorian)!
    var date = Date()
    
    var steps: Int! = 0
    var coreMotionPedometer = CMPedometer()
    
    var timer = Timer()
    let timerInterval = 1.0
    var timeElapsed: TimeInterval = 0.0
    
    var resultDictionary: [String: Int] = [:]
    var dateComponents: DateComponents!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startStopButton.setTitle("Start", for: .normal)
        self.startStopButton.backgroundColor = UIColor(hex: "74d01b")
        self.startStopButton.addTarget(self, action: #selector(buttonPushed), for: .touchDown)
    }
    
    //Timer methods
    
    //convert seconds to hh:mm:ss as a string
    private func timeIntervalFormat(interval: TimeInterval) -> String {
        var seconds = Int(interval + 0.5) //round up seconds
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    public func startTimer() {
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
    }
    
    public func stopTimer() {
        timer.invalidate()
        displayPedometerData()
    }
    
    public func displayPedometerData() {
        //Time Elapsed
        timeElapsed += self.timerInterval
        
        self.timeLabel.text = timeIntervalFormat(interval: timeElapsed).description
        
        //Number of steps
        self.stepsLabel.text = steps.description
    }
    
    //Targets
    
    //Formatting date
    @objc func buttonPushed(_ sender: UIButton) {
        self.dateComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: date)
        
        if sender.titleLabel?.text == "Start"{
            //Starting the pedometer
            coreMotionPedometer = CMPedometer()
            self.startTimer()
            coreMotionPedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
                if let pedData = pedometerData{
                    DispatchQueue.main.async {
                    self.stepsLabel.text = "\(pedData.numberOfSteps)"
                    }
                } else {
                    self.stepsLabel.text = "Not Available"
                }
            })
            
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = UIColor(hex: "d41c1c")
        } else {
            //Stopping the pedometer
            coreMotionPedometer.stopUpdates()
            self.stopTimer()
            sender.backgroundColor = UIColor(hex: "74d01b")
            sender.setTitle("Start", for: .normal)
            
            if modelController.model.resDict.keys.contains(dateComponents.description) {
                self.resultDictionary[dateComponents.description]! += steps
                self.modelController.model = Model(resDict: resultDictionary)
                print("\(modelController.model.resDict) + CASE 1")
            } else {
                self.resultDictionary.updateValue(steps, forKey: dateComponents.description)
                self.modelController.model = Model(resDict: resultDictionary)
                print("\(modelController.model.resDict) + CASE 2")
            }
        }
    }
    
    @objc func timerAction(timer: Timer) {
        displayPedometerData()
    }
}
