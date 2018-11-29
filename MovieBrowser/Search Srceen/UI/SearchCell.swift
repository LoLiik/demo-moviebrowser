//
//  SearchCell.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var favoriteImageVIewWidth: NSLayoutConstraint!
    @IBOutlet weak var posterImageView: PostImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var originalTitle: UILabel!
    @IBOutlet weak var releaseYear: UILabel!
    @IBOutlet weak var favoriteImageView: UIImageView!

    var movie: Movie? { didSet { updateUI() } }
    var favorite: Bool? { didSet { self.displayFavoriteImage() }}

    // Displays Image if current movie is one of favorite movies
    func displayFavoriteImage() {
        guard favorite != nil else {return}
        if favorite!{
            favoriteImageVIewWidth.constant = 50
        } else {
            favoriteImageVIewWidth.constant = 0
        }
    }

    private func updateUI() {
        if favorite == nil{
            favorite = false
        }

        if let newMovie = movie{

            title?.text = movie?.title
            if newMovie.title == newMovie.original_title{
                originalTitle.isHidden = true
            } else {
                originalTitle.isHidden = false
                originalTitle.text = newMovie.original_title
            }

            releaseYear.text = self.getYear(from: newMovie.release_date)

            if let posterImageURL = newMovie.poster_path {
                posterImageView.loadImageUsingUrlString(urlString: IMAGE_URL + "/w154" + posterImageURL)
            }
        } else {
            return
        }
    }

    private func getYear(from stringWithYear: String) -> String{
        if let movieDate = DateFormatter.yearFormatter.date(from: stringWithYear){
            let calendar = Calendar.current
            if let year = calendar.dateComponents([.year], from: movieDate).year{
                return "\(year)"
            }
        }
        return ""
    }
}

extension DateFormatter{
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}
