//
//  TabBuilder.swift
//  Created by YPY Global on 1/9/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import UIKit

open class TabBuilder {
    
    static func segmentioStates(_ font: UIFont, _ normalColor: UIColor, _ focusColor: UIColor) -> SegmentioStates {
        return SegmentioStates(
            defaultState: segmentioState(
                backgroundColor: UIColor.clear,
                titleFont: font,
                titleTextColor: normalColor
            ),
            selectedState: segmentioState(
                backgroundColor: UIColor.clear,
                titleFont: font,
                titleTextColor: focusColor
            ),
            highlightedState: segmentioState(
                backgroundColor: UIColor.clear,
                titleFont: font,
                titleTextColor: focusColor
            )
        )
    }
    
    static func segmentioState(backgroundColor: UIColor, titleFont: UIFont, titleTextColor: UIColor) -> SegmentioState {
        return SegmentioState(
            backgroundColor: backgroundColor,
            titleFont: titleFont,
            titleTextColor: titleTextColor
        )
    }
    
    static func segmentioIndicatorOptions(_ color: UIColor, _ height: CGFloat) -> SegmentioIndicatorOptions {
        return SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: height,
            color: color
        )
    }
    
    static func segmentioHorizontalSeparatorOptions(_ color: UIColor) -> SegmentioHorizontalSeparatorOptions {
        return SegmentioHorizontalSeparatorOptions(
            type: .bottom,
            height: 1,
            color: color
        )
    }
    
    static func segmentioVerticalSeparatorOptions(_ color: UIColor) -> SegmentioVerticalSeparatorOptions {
        return SegmentioVerticalSeparatorOptions(
            ratio: 0,
            color: color
        )
    }
}
