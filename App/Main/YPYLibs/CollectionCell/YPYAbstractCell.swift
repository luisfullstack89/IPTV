//
//  YPYAbstractCell.swift
//  Created by YPY Global on 9/4/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class YPYAbstractCell: UICollectionViewCell {
    
    var model: JsonModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(_ model: JsonModel ){
        self.model = model
    }
   
}
