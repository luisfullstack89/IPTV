//
//  GenreCardGridCell.swift
//  Created by Do Trung Bao on 1/28/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import UIKit

class GroupCardGridCell: GroupAbstractCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.rootLayout.backgroundColor = getColor(hex: ColorRes.grid_view_bg_color)
        self.lblName.textColor = getColor(hex: ColorRes.grid_view_main_color_text)
    }
    
}
