//
//  Movie.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import Foundation

struct Movie: Codable{
    let id: Int
    let vote_count: Int
    let vote_average: Double
    let title: String
    let original_title: String
    let poster_path: String?
    let backdrop_path: String?
    let overview: String
    let release_date: String
}
