//
//  SerieCell.swift
//  iptv-pro
//
//  Created by YPY Global on 8/17/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class SerieCell: YPYAbstractCell {
    
    @IBOutlet weak var imgSerie: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubInfo: UILabel!
    
    var favDelegate: FavoriteDelegate?
    let urlEnpoint = SettingManager.getUrlEnpoint()
    
    override func updateUI(_ model: JsonModel){
        super.updateUI(model)
        let serie = model as? SeriesModel
        self.lblName.text = serie?.name
        self.lblSubInfo.text =  serie?.getDateStr()
        let imgItem =  serie?.getUriArtwork(urlEnpoint) ?? ""
        if !imgItem.isEmpty && imgItem.starts(with: "http") {
            self.imgSerie.kf.setImage(with: URL(string: imgItem), placeholder:  UIImage(named: ImageRes.ic_film_default))
        }
        else{
            self.imgSerie.image = UIImage(named: ImageRes.ic_film_default)
        }
    }
    
}
