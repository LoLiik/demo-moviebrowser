//
//  MovieResponse.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import Foundation

struct MovieResponse: Codable {
    let currentPage: Int
    let totalPages: Int
    let movies: [Movie]

    private enum CodingKeys: String, CodingKey{
        case currentPage = "page"
        case totalPages = "total_pages"
        case movies = "results"
    }
    
}
