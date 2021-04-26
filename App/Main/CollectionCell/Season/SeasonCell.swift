//
//  SeasonCell.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class SeasonCell: YPYAbstractCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    override func updateUI(_ model: JsonModel) {
        super.updateUI(model)
        let season = model as? SeasonModel
        self.lblName.text = season?.name
        self.lblInfo.text = season?.getDateStr()
    }
}
