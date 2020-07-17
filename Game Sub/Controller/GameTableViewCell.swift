//
//  GameTableViewCell.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 17/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewCell.layer.cornerRadius = 20
        
        viewCell.layer.shadowColor = UIColor.black.cgColor
        viewCell.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        viewCell.layer.shadowOpacity = 0.5
        viewCell.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
