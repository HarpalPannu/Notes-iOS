//
//  FilterCell.swift
//  Notes
//
//  Created by Mac on 4/4/18.
//  Copyright © 2018 Harpal. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                self.layer.backgroundColor = UIColor.red.cgColor
            }
            else
            {
                self.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
}
