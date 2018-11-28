//
//  NoteTableViewCell.swift
//  FirebaseInClass01
//
//  Created by Snigdha Bose on 11/10/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var delete: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
