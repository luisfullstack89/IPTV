//
//  GradientUtils
//  Created by YPY Global on 1/26/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import UIKit

open class UIAppUtils {
    
//    public static func setStatusBarStyle(hexColor : String) {
//        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
//            statusBar.setValue(getColor(hex: hexColor), forKey: "foregroundColor")
//        }
//    }
    
    public static func startAndEndPoints(from angle: Int) -> (startPoint:CGPoint, endPoint:CGPoint) {
        // Set default points for angle of 0°
        var startPointX: CGFloat = 0.5
        var startPointY: CGFloat = 1.0
        
        // Define point objects
        var startPoint: CGPoint
        var endPoint: CGPoint
        
        // Define points
        switch true {
            
        //LEFT_RIGHT
        case angle == 0:
            startPointX = 0.0
            startPointY = 0.0
            
        //BL_TR
        case angle == 45:
            startPointX = 0.0
            startPointY = 1.0
            
        //BOTTOM_TOP
        case angle == 90:
            startPointX = 0.5
            startPointY = 1.0
            
        //BR_TL
        case angle == 135:
            startPointX = 1.0
            startPointY = 1.0
            
        //RIGHT_LEFT
        case angle == 180:
            startPointX = 1.0
            startPointY = 0.5
            
        //TR_BL
        case angle == 225:
            startPointX = 1.0
            startPointY = 0.0
            
        //TOP_BOTTOM
        case angle == 270:
            startPointX = 0.5
            startPointY = 0.0
        //TL_BR
        case angle == 315:
            startPointX = 0.0
            startPointY = 0.0
        default:
            startPointX = 0.0
            startPointY = 0.0
            break
        }
        // Build return CGPoints
        startPoint = CGPoint(x: startPointX, y: startPointY)
        endPoint = startPoint.opposite()
        // Return CGPoints
        return (startPoint, endPoint)
    }
    
    public static func getCAGradientLayer(viewBg : UIView,startColor: UIColor,
                            endColor: UIColor, orientation: CGFloat,
                            width: CGFloat, height: CGFloat) -> CAGradientLayer{
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        let listPoint = UIAppUtils.startAndEndPoints(from: Int(orientation))
        
        gradientLayer.startPoint = listPoint.startPoint
        gradientLayer.endPoint = listPoint.endPoint
        gradientLayer.frame = CGRect(x: viewBg.bounds.origin.x, y: viewBg.bounds.origin.y, width: width, height: height)
        
        return gradientLayer
    }
    
    private static func imageWithLayer(layer: CAGradientLayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    //default will be top left  bottom right
    public static func setColor(_ view : UIView, _ colorStart: String ,_ colorEnd: String, _ orientation: Int){
        let sizeW: CGFloat = view.bounds.width
        let sizeH: CGFloat = view.bounds.height
        setColor(view, colorStart, colorEnd,orientation, sizeW, sizeH)
    }
    
    //default will be top left  bottom right
    public static func setColor(_ view : UIView, _ colorStart: String ,_ colorEnd: String, _ orientation: Int ,_ sizeW: CGFloat, _ sizeH: CGFloat){
        let layer = getCAGradientLayer(viewBg: view, startColor: getColor(hex: colorStart), endColor: getColor(hex: colorEnd), orientation: CGFloat(orientation), width: sizeW , height: sizeH)
        let imageLayer = imageWithLayer(layer: layer)
        view.backgroundColor = UIColor(patternImage: imageLayer)
    }
    
   
}

extension Int {
    
    func degreesToRads() -> Double {
        return (Double(self) * .pi / 180)
    }
}

extension CGPoint {

    func opposite() -> CGPoint {
        // Create New Point
        var oppositePoint = CGPoint()
        // Get Origin Data
        let originXValue = self.x
        let originYValue = self.y
        // Convert Points and Update New Point
        oppositePoint.x = 1.0 - originXValue
        oppositePoint.y = 1.0 - originYValue
        return oppositePoint
    }
}

public extension CAGradientLayer {
    func gradientPointsForAngle(_ angle: CGFloat) -> [CGPoint] {
        // get vector start and end points
        let end = pointForAngle(angle)
        let start = oppositePoint(end)
        // convert to gradient space
        let p0 = transformToGradientSpace(end)
        let p1 = transformToGradientSpace(start)
        return [p0,p1]
    }
    func pointForAngle(_ angle: CGFloat) -> CGPoint {
        // convert degrees to radians
        let radians = angle * .pi / 180.0
        var x = cos(radians)
        var y = sin(radians)
        // (x,y) is in terms unit circle. Extrapolate to unit square to get full vector length
        if (abs(x) > abs(y)) {
            // extrapolate x to unit length
            x = x > 0 ? 1 : -1
            y = x * tan(radians)
        } else {
            // extrapolate y to unit length
            y = y > 0 ? 1 : -1
            x = y / tan(radians)
        }
        return CGPoint(x: x, y: y)
    }
    
    private func oppositePoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }
    
    private func transformToGradientSpace(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: (point.x + 1) * 0.5, y: 1.0 - (point.y + 1) * 0.5)
    }
}

enum VerticalLocation: String {
    case bottom
    case top
}
