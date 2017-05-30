//
//  DatePickerPopoverVC.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 16/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//


protocol UpdatingDateDelegate {
    func updateDateLabel( newDate: Date)
}


import UIKit

class DatePickerPopoverVC: UIViewController {
    
//   -------IB Outlets---------------------------
    @IBOutlet weak var datePicker: UIDatePicker!

//   -------Declare Variables---------------------------
    var delegate : UpdatingDateDelegate?

//   -------Main View Events---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date() // set minimum date to 'today'

        datePicker.addTarget(self, action: #selector(DatePickerPopoverVC.datePickerChanged), for: UIControlEvents.valueChanged) // trigger updating function each time the date is changed
    }

//   -------Methods---------------------------

    /// update label text in previous VC through protocol function
    func datePickerChanged(datePicker:UIDatePicker) {
        delegate?.updateDateLabel(newDate: datePicker.date)
    }

//   -------General---------------------------
    
    
    

}
