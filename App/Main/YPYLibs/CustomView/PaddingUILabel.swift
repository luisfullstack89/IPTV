//
//  PaddingUILabel.swift
//  NewAppRadio
//
//  Created by Do Trung Bao on 7/9/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class PaddingUILabel : UILabel {
    @IBInspectable var paddingTop: CGFloat = 0
    @IBInspectable var paddingBottom: CGFloat = 0
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        super.drawText(in: rect.inset(by: insets))
    }
    
    public override var intrinsicContentSize: CGSize{
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += paddingTop + paddingBottom
            contentSize.width +=  paddingLeft + paddingRight
            return contentSize
        }
    }
    
    
}
