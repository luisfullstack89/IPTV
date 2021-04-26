//
//  GenreFlatListCell.swift
//  Created by YPY Global on 1/5/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import UIKit

class GroupFlatListCell: GroupAbstractCell {

    @IBOutlet var divider: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rootLayout.backgroundColor = getColor(hex: ColorRes.list_view_bg_color)
        self.lblName.textColor = getColor(hex: ColorRes.list_view_color_main_text)
        self.divider.backgroundColor = getColor(hex: ColorRes.list_view_color_divider)
    }
    
}
