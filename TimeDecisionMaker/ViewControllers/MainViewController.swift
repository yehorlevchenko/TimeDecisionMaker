//
//  MainViewController.swift
//  TimeDecisionMaker
//
//  Created by Mikhail on 4/24/19.
//

import UIKit
import EventKit

class MainViewController: UIViewController {
    
    let appointmentWorker = AppointmentWorker()
    let date = Date()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateComponentsFormatter()
    let calendar = Calendar.current
    var calendarOwner = "A"
    var appointments = [Appointment]()
    var appointmentsForMonth = [Int: Appointment]()
    var appointmentsForDay = [Appointment]()
    var appointmentPicked: Appointment?
    private var currentDay: Int?
    private var currentMonth: Int?
    private var currentYear: Int?
    private var calendarDayOffset: Int?
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var dayTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        dayTableView.delegate = self
        dayTableView.dataSource = self
        
        timeFormatter.allowedUnits = [.hour, .minute]
        timeFormatter.unitsStyle = .positional
        
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        currentDay = calendar.component(.day, from: date)
//        currentMonth = calendar.component(.month, from: date)
        currentMonth = 4 // Hardcoded for the given calendar
        currentYear = calendar.component(.year, from: date)
        
        prepareData()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "\(DateFormatter().monthSymbols[currentMonth! - 1]) \(currentYear!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(changePerson))
        
        // Setup Calendar Collection View
        calendarDayOffset = date.getDayOfWeek(year: currentYear!, month: currentMonth!, day: 1)
        let columnLayout = CalendarFlowLayout(
            cellsPerRow: 7,
            minimumInteritemSpacing: 10,
            minimumLineSpacing: 10,
            sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
        calendarCollectionView.collectionViewLayout = columnLayout
        calendarCollectionView.contentInsetAdjustmentBehavior = .always
        
    }
    
    func prepareData() {
        appointmentWorker.parseAppointments(from: calendarOwner)
    
        appointments.removeAll()
        appointmentsForMonth.removeAll()
        appointmentsForDay.removeAll()
        loadDays()
        appointmentsForMonth = appointmentWorker.filterAppointmentsByMonth(currentMonth!, in: appointmentsForMonth)
        calendarCollectionView.reloadData()
        loadAppointmentsForDay(for: currentDay!)
        dayTableView.reloadData()
    }
    
    func loadDays() {
        let numberOfDays = date.getNumberOfDaysInMonth(month: currentMonth!, year: currentYear!)
        for day in 1...numberOfDays {
            appointmentsForMonth[day] = nil
        }
    }
    
    func loadAppointmentsForDay(for day: Int) {
        currentDay = day
        appointmentsForDay = appointmentWorker.filterAppointmentsByDay(day: day, month: currentMonth!)
        appointmentsForDay.sort(by: { $0.dateOfStart < $1.dateOfStart })
        navigationItem.title = "\(DateFormatter().monthSymbols[currentMonth! - 1]) \(currentDay!),\(currentYear!)"
        dayTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAppointmentSegue" {
            let vc = segue.destination as! AppointmentViewController
            vc.appointment = appointmentPicked
            vc.appointmentOwner = calendarOwner
        }
    }
    
    @objc func changePerson() {
        let ac = UIAlertController(title: "Change calendar", message: "Choose your pokemon", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Person A", style: .default, handler: { (_) in
            self.calendarOwner = "A"
            self.prepareData()
            }))
        ac.addAction(UIAlertAction(title: "Person B", style: .default, handler: { (_) in
            self.calendarOwner = "B"
            self.prepareData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 35
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! DayCollectionCell
        cell.tag = indexPath.row + 1
        cell.cleanCell()
        if let calendarDayOffset = calendarDayOffset {
            if calendarDayOffset <= indexPath.row && indexPath.row <= 31 {
                cell.dayLabel.text = String(indexPath.row + 1)
                
                if appointmentsForMonth[indexPath.row + 1] != nil {
                    cell.backgroundColor = UIColor.lightGray
                    cell.hasData = true
                    cell.showAppointmentLabel()
                } else {
                    cell.backgroundColor = UIColor.gray
                    cell.hasData = true
                }
            } else {
                cell.dayLabel.text = ""
                cell.backgroundColor = UIColor.darkGray
                cell.hasData = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionCell {
            currentDay = cell.tag
            if cell.hasData == true {
                loadAppointmentsForDay(for: currentDay!)
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if appointmentsForDay.count == 0 {
            return 1
        } else {
            return appointmentsForDay.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "hourCell")
        if appointmentsForDay.count <= 1 {
            cell.textLabel?.text = "Enjoy your freedom!"
        } else {
            let appointment = appointmentsForDay[indexPath.row]
            let startDateComponents = calendar.dateComponents([.hour, .minute], from: appointment.dateOfStart)
            let startTime = timeFormatter.string(from: startDateComponents)
            let endDateComponents = calendar.dateComponents([.hour, .minute], from: appointment.dateOfEnd)
            let endTime = timeFormatter.string(from: endDateComponents)
            
            cell.textLabel?.text = appointment.summary
            cell.detailTextLabel?.text = startTime! + " - " + endTime!
            cell.accessoryType = .detailButton
        }

        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.textLabel?.text != "Enjoy your freedom!" {
            appointmentPicked = appointmentsForDay[indexPath.row]
            performSegue(withIdentifier: "ShowAppointmentSegue", sender: self)
        }
        
    }
}
