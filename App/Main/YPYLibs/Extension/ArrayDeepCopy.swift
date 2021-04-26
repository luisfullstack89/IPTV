//
//  ArrayDeepCopy.swift
//  NewAppRadio
//
//  Created by Do Trung Bao on 7/8/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation


//Array extension for elements conforms the Copying protocol
extension Array where Element: JsonModel {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            if let copyModel = element.copy() as? Element {
                copiedArray.append(copyModel)
            }
        }
        return copiedArray
    }
}
