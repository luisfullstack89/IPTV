//
//  AutoFillButton.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/14/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class AutoFillButton : UIButton {
    
    @IBInspectable var textId: String = ""
    
    public override func draw(_ rect: CGRect) {
        if !textId.isEmpty {
            self.setTitle(getString(textId), for: .normal)
        }
        super.draw(rect)
    }
}

