//
//  ProgressTableViewCell.swift
//  BrushYourTeeth
//
//  Created by Hakeem Deggs on 2/19/22.
//

import UIKit
protocol SaveContextProtcol {
    func saveContext(morning: Bool, night: Bool)
}

class ProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var weekDays: UILabel!
    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var nightSwitch: UISwitch!
    @IBOutlet weak var nightTextLabel: UILabel!
    @IBOutlet weak var morningTextLabel: UILabel!
   
    var delegate: SaveContextProtcol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
    }

    
    
    @IBAction func morningSwitchToggled(_ sender: UISwitch) {
        
        delegate?.saveContext(morning: morningSwitch.isOn, night: nightSwitch.isOn)
    
    
    }
    

}
