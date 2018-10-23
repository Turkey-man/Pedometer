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
    
    var steps = 0
    var coreMotionPedometer = CMPedometer()
    
    var timer = Timer()
    let timerInterval = 1.0
    var timeElapsed: TimeInterval = 0.0
    
    var resultDictionary: [String: Int] = [:]
    var dateComponents: DateComponents!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var button =  self.startStopButton
        button?.setTitle("Start", for: .normal)
        button?.backgroundColor = UIColor(hex: "74d01b")
        button?.addTarget(self, action: #selector(buttonPushed), for: .touchDown)
        //let dataDict = UserDefaults.value(forKey: "dateAndStepsDictionary")
    }
    
    //MARK:- Timer methods
    
    //MARK:- convert seconds to hh:mm:ss as a string
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
    
    private func startCountingSteps() {
        self.coreMotionPedometer.startUpdates(from: self.date) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else {
                self?.stepsLabel.text = "Not Available"
                return
            }
            self?.steps = pedometerData.numberOfSteps.intValue
        }
    }
    
    private func displayPedometerData() {
        //Time Elapsed
        timeElapsed += self.timerInterval
        
        self.timeLabel.text = self.timeIntervalFormat(interval: timeElapsed).description
        
        //Number of steps
        self.stepsLabel.text = self.steps.description
        UILabel.transition(with: self.stepsLabel,
                           duration: 0.50,
                           options: .transitionCrossDissolve,
                           animations: nil,
                           completion: nil)
    }

    //MARK:- Targets
    
    //MARK:- Formatting date
    @objc func buttonPushed(_ sender: UIButton) {
        self.dateComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: date)
        
        if sender.titleLabel?.text == "Start"{
            //MARK:- Starting the pedometer
            coreMotionPedometer = CMPedometer()
            self.startTimer()
            self.startCountingSteps()
            
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = UIColor(hex: "d41c1c")
        } else {
            //MARK:- Stopping the pedometer
            self.stopTimer()
            self.coreMotionPedometer.stopUpdates() //stop counting steps
            sender.backgroundColor = UIColor(hex: "74d01b")
            sender.setTitle("Start", for: .normal)
            fillingDictionaryWithData()
        }
    }
    
    func fillingDictionaryWithData() {
        if modelController.model.resDict.keys.contains(dateComponents.description) {
                self.resultDictionary[dateComponents.description]! += steps
                self.modelController.model = Model(resDict: resultDictionary)
                }
                //MARK:- No previous records for today
            else {
                self.resultDictionary.updateValue(steps, forKey: dateComponents.description)
                self.modelController.model = Model(resDict: resultDictionary)
            }
    }
    
    @objc func timerAction(timer: Timer) {
        displayPedometerData()
    }
}
