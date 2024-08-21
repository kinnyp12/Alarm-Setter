//
//  SetAlarmViewController.swift
//  Alarm Setter
//
//  Created by Kinny Padia on 21/08/24.
//

import UIKit
import Foundation
import UserNotifications

protocol SetAlarmDelegate: AnyObject {
    func didSaveAlarm(alarm: Alarm)
}

class SetAlarmViewController: UIViewController {
    
    weak var delegate: SetAlarmDelegate?
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var dailySwitch: UISwitch!
    @IBOutlet weak var dayButtonsStackView: UIStackView!
    
    var selectedDays: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dailySwitchChanged(_ sender: UISwitch) {
        dayButtonsStackView.isHidden = sender.isOn
    }
        
    @IBAction func dayButtonTapped(_ sender: UIButton) {
        if selectedDays.contains(sender.tag) {
            selectedDays.removeAll(where: { $0 == sender.tag })
            sender.backgroundColor = .lightGray
        } else {
            selectedDays.append(sender.tag)
            sender.backgroundColor = .darkGray
        }
    }
    
    @IBAction func saveAlarmTapped(_ sender: UIBarButtonItem) {
        let alarm = Alarm(time: timePicker.date, reason: reasonTextField.text ?? "", isDaily: dailySwitch.isOn, repeatDays: dailySwitch.isOn ? [] : selectedDays)
        scheduleNotification(for: alarm)
        delegate?.didSaveAlarm(alarm: alarm)
        navigationController?.popViewController(animated: true)
    }
}

extension SetAlarmViewController{
    
    func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = alarm.reason
        content.sound = UNNotificationSound.default
        
        var trigger: UNNotificationTrigger?
        
        if alarm.isDaily {
            var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            dateComponents.second = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        } else if !alarm.repeatDays.isEmpty {
            for day in alarm.repeatDays {
                var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
                dateComponents.weekday = day
                dateComponents.second = 0
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification:", error)
                    }
                }
            }
            return
        }
        
        if let trigger = trigger {
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification:", error)
                }
            }
        }
    }

}

struct Alarm {
    var time: Date
    var reason: String
    var isDaily: Bool
    var repeatDays: [Int]
}
