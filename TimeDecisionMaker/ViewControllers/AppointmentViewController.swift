//
//  AppointmentViewController.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 5/31/19.
//

import UIKit

class AppointmentViewController: UITableViewController {
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let decisionMaker = RDTimeDecisionMaker()
    var appointmentOwner: String?
    var appointment: Appointment?
    var appointmentDuration: TimeInterval?
    var startPickerHidden = true
    var endPickerHidden = true
    var collaboratePickerHidden = true
    var collaborationSlots = [DateInterval]()
    
    @IBOutlet weak var appointmentDurationLabel: UILabel!
    @IBOutlet weak var appointmentEnds: UILabel!
    @IBOutlet weak var appointmentStarts: UILabel!
    @IBOutlet weak var appointmentDescription: UILabel!
    @IBOutlet weak var appointmentSummary: UILabel!
    @IBOutlet weak var startsPicker: UIDatePicker!
    @IBOutlet weak var startsPickerCell: UITableViewCell!
    @IBOutlet weak var endsPickerCell: UITableViewCell!
    @IBOutlet weak var endsPicker: UIDatePicker!
    @IBOutlet weak var collaborateLabel: UILabel!
    @IBOutlet weak var collaborateSlotPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collaborateSlotPicker.delegate = self
        formatter.dateFormat = "HH:mm MM/dd/yyyy"
        
        navigationItem.title = "Edit Event"
        setData()
    }
    
    func setData() {
        if appointment?.eventDescription != "" {
            appointmentDescription.text = appointment?.eventDescription
            appointmentDescription.textColor = UIColor.black
        } else {
            appointmentDescription.text = "Event description"
            appointmentDescription.textColor = UIColor.lightGray
        }
        
        appointmentSummary.text = appointment?.summary
        appointmentStarts.text = formatter.string(from: appointment!.dateOfStart)
        appointmentEnds.text = formatter.string(from: appointment!.dateOfEnd)
        let diff = calendar.dateComponents([.hour], from: appointment!.dateOfStart, to: appointment!.dateOfEnd)
        appointmentDuration = TimeInterval(integerLiteral: Int64(diff.hour!))
        appointmentDurationLabel.text = "\(Int(appointmentDuration!)) h"
        
        startsPicker.date = appointment!.dateOfStart
        endsPicker.date = appointment!.dateOfEnd
    }
    
    func prepareCollaborationSlots() {
        if collaborationSlots.count == 0 {
            let alert = UIAlertController(title: "No free slots", message: "There are no free slots in the nearest future.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else if collaborationSlots.count == 1 && Int(collaborationSlots.first!.duration) >= 600000 {
            let alert = UIAlertController(title: "Any time is good", message: "Attendee has no appointments for the next week.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else {
            collaboratePickerHidden = !collaboratePickerHidden
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: false)
        switch cell?.reuseIdentifier {
        case "summary":
            print("Not implemented")
        case "description":
            print("Not implemented")
        case "starts":
            startPickerHidden = !startPickerHidden
            endPickerHidden = true
            tableView.reloadData()
        case "ends":
            endPickerHidden = !endPickerHidden
            startPickerHidden = true
            tableView.reloadData()
        case "duration":
            print("Not implemented")
        case "collaborate":
            let attendeeICS = appointmentOwner == "A" ? "B" : "A"
            collaborationSlots = decisionMaker.suggestAppointments(organizerICS: appointmentOwner!, attendeeICS: "B", duration: appointmentDuration!)
            prepareCollaborationSlots()
        default:
            print("Unknown input")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell?.reuseIdentifier {
        case "startsPicker":
            if startPickerHidden == true {
                return 0.0
            } else {
                return startsPicker.frame.height
            }
        case "endsPicker":
            if endPickerHidden == true {
                return 0.0
            } else {
                return endsPicker.frame.height
            }
        case "collaboratePicker":
            if collaboratePickerHidden == true {
                return 0.0
            } else {
                return collaborateSlotPicker.frame.height
            }
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // MARK: DatePickers
    @IBAction func startPickerChanged(_ sender: Any) {
        appointment?.dateOfStart = startsPicker.date
        setData()
    }
    
    @IBAction func endPickerChanged(_ sender: Any) {
        appointment?.dateOfEnd = endsPicker.date
        setData()
    }
}

extension AppointmentViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Picked")
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let slot = collaborationSlots[row]
        let rowName = "\(slot.start) - \(slot)"
        return rowName
    }
}
