//  TableViewCell.swift
//  Notes
//  Created by Mac on 3/28/18.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var date: UILabel!
    @IBOutlet var title: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
