//
//  PersonDataTableViewCell.swift
//  SUSHMobileTask
//
//  Created by Yanbing Peng on 14/06/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import UIKit

class PersonDataTableViewCell: UITableViewCell {

    // MARK: - Outlets
    var currentRowIndex : Int = -1  

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
