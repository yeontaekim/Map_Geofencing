//
//  FavoriteTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/1/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var scientificName: UILabel!
    @IBOutlet weak var commonName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
