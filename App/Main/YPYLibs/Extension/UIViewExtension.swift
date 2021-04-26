//
//  UIViewExtension.swift
//  iLandMusic
//
//  Created by iLandMusic on 8/25/19.
//  Copyright © 2019 iLandMusic. All rights reserved.
//

import Foundation
import UIKit


extension UIView{
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.75, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -10), color: color, opacity: opacity, radius: radius)
        }
    }
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.75, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
}


extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

extension UIImage {
    
    //make image with color
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    //make image with tintcolor
    func setTintColor(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)

        color.setFill()
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        newImage.accessibilityIdentifier = accessibilityIdentifier
        return newImage
    }
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let height  = self.frame.height
        
        let iconView = UIImageView(frame: CGRect(x: 6, y: 4, width: 24, height: 24))
        iconView.image = image
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: (height-36)/2, width: 36, height: 36))
        iconContainerView.addSubview(iconView)
        
        leftView = iconContainerView
        leftViewMode = .always
    }

    func placeholderColor(color: UIColor) {
        let attributeString = [
            NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.6),
            NSAttributedString.Key.font: self.font!
            ] as [NSAttributedString.Key : Any]
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: attributeString)
    }
    
    func setBottomBorder(withColor color: UIColor){
        self.borderStyle = UITextField.BorderStyle.none
        self.backgroundColor = UIColor.clear
        let height: CGFloat = 1.0
        let borderLine = UIView(frame: CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height))
        borderLine.backgroundColor = color
        self.addSubview(borderLine)
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension UITextView {
    
    func setHtmlString(_ htmlStr: String?, _ color: UIColor? = .black,
                       _ font: UIFont? = UIFont.systemFont(ofSize: 14), _ style: NSMutableParagraphStyle? = nil){
        if htmlStr != nil && !htmlStr!.isEmpty {
            let htmlData = htmlStr!.data(using: .unicode, allowLossyConversion: true)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attributedString = try! NSMutableAttributedString(data: htmlData!,options: options,documentAttributes: nil)
            attributedString.addAttribute(.foregroundColor, value: color!, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.font, value: font!, range: NSRange(location: 0, length: attributedString.length))
            if style != nil {
                attributedString.addAttribute(.paragraphStyle, value: style!, range: NSRange(location: 0, length: attributedString.length))
            }
            self.attributedText = attributedString
            
        }
    }
}
extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            return scrollView?.isScrollEnabled ?? false
        }
        set {
            scrollView?.isScrollEnabled = newValue
        }
    }

    var scrollView: UIScrollView? {
        return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}
