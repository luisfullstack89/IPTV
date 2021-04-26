//
//  AutoFilTextField.swift
//  iptv-pro
//
//  Created by YPY Global on 8/14/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class AutoFillTextField : UITextField {
    
    @IBInspectable var placeHolderId: String = ""
    @IBInspectable var paddingTop: CGFloat = 0.0
    @IBInspectable var paddingBottom: CGFloat = 0.0
    @IBInspectable var paddingLeft: CGFloat = 0.0
    @IBInspectable var paddingRight: CGFloat = 0.0
    
    private var edgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    private func initEdges() {
        self.edgeInsets.left = paddingLeft
        self.edgeInsets.right = paddingRight
        self.edgeInsets.top = paddingTop
        self.edgeInsets.bottom = paddingBottom
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        self.initEdges()
        return bounds.inset(by: edgeInsets)
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        self.initEdges()
        return bounds.inset(by: edgeInsets)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        self.initEdges()
        return bounds.inset(by: edgeInsets)
    }
    
    public override func drawText(in rect: CGRect) {
        if !placeHolderId.isEmpty {
            self.placeholder = getString(placeHolderId)
        }
        super.drawText(in: rect)
    }

    
}
