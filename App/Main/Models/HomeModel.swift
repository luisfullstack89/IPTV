//
//  HomeModel.swift
//  iptv-pro
//
//  Created by YPY Global on 8/17/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
public class HomeModel : JsonModel {
    
    var featuredMovies: [MovieModel]?
    var newestMovies: [MovieModel]?
    var series: [SeriesModel]?
    var genres: [GenreModel]?
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let featureds = dictionary?["featured_movies"] as? [[String:Any]] {
            self.featuredMovies = []
            for dict in featureds {
                let movie = MovieModel()
                movie.initFromDict(dict)
                self.featuredMovies?.append(movie)
            }
        }
        if let newest = dictionary?["newest_movies"] as? [[String:Any]] {
            self.newestMovies = []
            for dict in newest {
                let movie = MovieModel()
                movie.initFromDict(dict)
                self.newestMovies?.append(movie)
            }
        }
        if let series = dictionary?["series"] as? [[String:Any]] {
            self.series = []
            for dict in series {
                let serie = SeriesModel()
                serie.initFromDict(dict)
                self.series?.append(serie)
            }
        }
        if let genres = dictionary?["genres"] as? [[String:Any]] {
            self.genres = []
            for dict in genres {
                let genre = GenreModel()
                genre.initFromDict(dict)
                self.genres?.append(genre)
            }
        }

    }
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        var size = self.featuredMovies?.count ?? 0
        if size > 0 {
            let featured = MovieModel.getDictFromList(self.featuredMovies!)
            dicts!.updateValue(featured, forKey: "featured_movies")
        }
        size = self.newestMovies?.count ?? 0
        if size > 0 {
            let newest = MovieModel.getDictFromList(self.newestMovies!)
            dicts!.updateValue(newest, forKey: "newest_movies")
        }
        size = self.series?.count ?? 0
        if size > 0 {
            let series = SeriesModel.getDictFromList(self.series!)
            dicts!.updateValue(series, forKey: "series")
        }
        size = self.genres?.count ?? 0
        if size > 0 {
            let genres = GenreModel.getDictFromList(self.genres!)
            dicts!.updateValue(genres, forKey: "genres")
        }
        return dicts
    }
    
    func onDestroy(){
        self.featuredMovies?.removeAll()
        self.featuredMovies = nil
        
        self.newestMovies?.removeAll()
        self.newestMovies = nil
        
        self.series?.removeAll()
        self.series = nil
        
        self.genres?.removeAll()
        self.genres = nil
    }
    
    func havingData() -> Bool {
        let featuredSize = self.featuredMovies?.count ?? 0
        let newestSize = self.newestMovies?.count ?? 0
        let seriesSize = self.series?.count ?? 0
        let genreSize = self.genres?.count ?? 0
        return featuredSize > 0 || newestSize > 0 || seriesSize > 0 || genreSize > 0
    }
    
    func updateFavorite() {
        let featuredSize = self.featuredMovies?.count ?? 0
        if featuredSize > 0 {
            TotalDataManager.shared.updateFavoriteForList(self.featuredMovies!)
        }
        let newestSize = self.newestMovies?.count ?? 0
        if newestSize > 0 {
            TotalDataManager.shared.updateFavoriteForList(self.newestMovies!)
        }
    }
    
}
