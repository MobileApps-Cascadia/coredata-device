//
//  CellTableViewCell.swift
//  coredata-device
//
//  Created by Student Account on 10/14/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import UIKit

class CellTableViewCell: UITableViewCell {

    @IBOutlet weak var serialNumberField: UILabel!
    @IBOutlet weak var deviceTypeField: UILabel!
    @IBOutlet weak var uuidField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
