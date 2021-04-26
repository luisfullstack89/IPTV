//
//  EpisodeCell.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class EpisodeCell: YPYAbstractCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    override func updateUI(_ model: JsonModel) {
        super.updateUI(model)
        let episode = model as? EpisodeModel
        self.lblName.text = episode?.name
        self.lblInfo.text = episode?.getDateStr()
    }
    
    
}

