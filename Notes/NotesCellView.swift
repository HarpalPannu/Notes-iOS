//  NotesCellView.swift
//  Notes
//  Created by Mac on 3/26/18.
//  Copyright © 2018 Harpal. All rights reserved.
//

import UIKit

class NotesCellView: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
 
    
}
class FilterTableCell: UITableViewCell {
    
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
