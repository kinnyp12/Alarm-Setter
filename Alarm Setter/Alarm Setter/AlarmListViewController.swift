//
//  ViewController.swift
//  Alarm Setter
//
//  Created by Kinny Padia on 21/08/24.
//

import UIKit

class AlarmListViewController: UIViewController {
    
    var alarms: [Alarm] = []
    weak var delegate: SetAlarmDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @IBAction func addAlarmTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let setAlarmVC = storyboard.instantiateViewController(withIdentifier: "SetAlarmViewController") as? SetAlarmViewController {
            setAlarmVC.delegate = self
            navigationController?.pushViewController(setAlarmVC, animated: true)
        }
    }
    
}

extension AlarmListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmCell
        let alarm = alarms[indexPath.row]
        cell.note.text = alarm.reason
        cell.alarmTime.text = DateFormatter.localizedString(from: alarm.time, dateStyle: .none, timeStyle: .short)
        if alarm.isDaily {
            cell.repeatDays.text = "Daily"
        } else {
            let days = alarm.repeatDays.map { DateFormatter().shortWeekdaySymbols[$0 - 1] }
            cell.repeatDays.text = days.joined(separator: ", ")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension AlarmListViewController: SetAlarmDelegate {
    func didSaveAlarm(alarm: Alarm) {
        alarms.append(alarm)
        tableView.reloadData()
    }
}


class AlarmCell: UITableViewCell{
    
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var repeatDays: UILabel!
}
