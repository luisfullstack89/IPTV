//
//  MovieCell.swift
//  iptv-pro
//
//  Created by YPY Global on 8/17/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class MovieCell: YPYAbstractCell {
    
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubInfo: UILabel!
    
    var favDelegate: FavoriteDelegate?
    let urlEnpoint = SettingManager.getUrlEnpoint()
    var typeVC: Int = 0

    override func updateUI(_ model: JsonModel){
        super.updateUI(model)
        let movie = model as? MovieModel
        let isFav = movie?.isFavorite ?? false
        self.btnFav.setImage(UIImage(named: isFav ? ImageRes.ic_heart_pink_36dp : ImageRes.ic_heart_outline_white_36dp), for: .normal)
        self.lblName.text = movie?.name
        
        let genre = movie?.genres ?? ""
        let date = movie?.getDateStr() ?? ""
        self.lblSubInfo.text = !genre.isEmpty ? genre : date
        let imgItem = movie?.getUriArtwork(urlEnpoint) ?? ""
        if !imgItem.isEmpty && imgItem.starts(with: "http") {
            self.imgMovie.kf.setImage(with: URL(string: imgItem), placeholder:  UIImage(named: ImageRes.ic_film_default))
        }
        else{
            self.imgMovie.image = UIImage(named: ImageRes.ic_film_default)
        }
    }
    
    @IBAction func favTap(_ sender: Any) {
        if let movie = self.model as? MovieModel {
            let isFav = movie.isFavorite
            self.favDelegate?.updateFavorite(movie,!isFav,self.typeVC)
        }
    }
}
