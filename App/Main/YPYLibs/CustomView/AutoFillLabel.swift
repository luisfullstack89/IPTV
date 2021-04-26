//
//  AutoFillLabel.swift
//  iptv-pro
//
//  Created by YPY Global on 8/12/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class AutoFillLabel : PaddingUILabel {
    @IBInspectable var textId: String = ""
    
    public override func drawText(in rect: CGRect) {
        if !textId.isEmpty {
            self.text = getString(textId)
        }
        super.drawText(in: rect)
    }
}
