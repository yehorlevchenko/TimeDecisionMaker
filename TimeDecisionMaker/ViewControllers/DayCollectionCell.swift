//
//  DayCollectionCell.swift
//  TimeDecisionMaker
//
//  Created by Yehor Levchenko on 5/19/19.
//

import UIKit

final class DayCollectionCell: UICollectionViewCell {

    var hasData = false

    @IBOutlet weak var dayLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showAppointmentLabel() {
        let labelSize = self.frame.width / 5
        let labelSizeOffset = labelSize / 4
        let label = UIView(frame: CGRect(x: self.frame.width - labelSizeOffset - labelSize, y: labelSizeOffset, width: labelSize, height: labelSize))
        label.tag = 99
        label.backgroundColor = UIColor.blue
        label.layer.cornerRadius = 5
        self.addSubview(label)
    }
    
    func cleanCell() {
        for subview in self.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
    }
}
