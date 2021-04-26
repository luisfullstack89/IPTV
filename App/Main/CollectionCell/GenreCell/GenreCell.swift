//
//  GenresFlatGridCell.swift
//  Created by YPY Global on 12/24/18.
//  Copyright © 2018 YPY Global. All rights reserved.
//

import UIKit

class GenreCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var rootLayout: UIView!
    
    private let chatArraysColors = ColorRes.array_genres_colors
    private var sizeArray: Int = 0
    
    var genre: GenreModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sizeArray = chatArraysColors.count
    }
    
    func updateUI(_ model: GenreModel, _ pos: Int) {
        self.genre = model
        self.lblName.text = model.name
        self.rootLayout.backgroundColor = getColor(hex: chatArraysColors[pos%self.sizeArray])
    }
    
}
