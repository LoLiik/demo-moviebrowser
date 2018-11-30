//
//  Movie.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object, Codable{
    @objc dynamic var id: Int
    @objc dynamic var vote_count: Int
    @objc dynamic var vote_average: Double
    @objc dynamic var title: String
    @objc dynamic var original_title: String
    @objc dynamic var poster_path: String?
    @objc dynamic var backdrop_path: String?
    @objc dynamic var overview: String
    @objc dynamic var release_date: String
    @objc dynamic var search = ""
    @objc dynamic var favorite = false

    override static func primaryKey() -> String{
        return "id"
    }

    private enum CodingKeys: String, CodingKey{
        case id
        case vote_count
        case vote_average
        case title
        case original_title
        case poster_path
        case backdrop_path
        case overview
        case release_date
    }
}

class Favorite: Movie{
}
