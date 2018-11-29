//
//  MovieViewController.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit
import RealmSwift

class MovieViewController: UITableViewController {

    @IBOutlet weak var addFavoriteButton: UIButton!
    @IBOutlet weak var posterImageView: PostImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalTitleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    var movie: Movie? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if let posterImageURL = movie?.poster_path {
            posterImageView.loadImageUsingUrlString(urlString: IMAGE_URL + "/w154" + posterImageURL)
        }
        updateUI()
    }

    private func updateUI() {
        updateFavoriteButton()
        if let newMovie = movie{
            titleLabel?.text = movie?.title
            if newMovie.title == newMovie.original_title{
                originalTitleLabel.isHidden = true
            } else {
                originalTitleLabel.isHidden = false
                originalTitleLabel.text = newMovie.original_title
            }
            overviewLabel?.text = newMovie.overview
            ratingLabel?.text = "\(newMovie.vote_average)/\(newMovie.vote_count)"
            //TODO: - apply dateFormatter
            releaseDateLabel.text = movie?.release_date

            if let posterImageURL = newMovie.poster_path {
        posterImageView.loadImageUsingUrlString(urlString: IMAGE_URL + "/original" + posterImageURL)
            }
        } else {
            return
        }
    }

    private func updateFavoriteButton(){
        guard let currentMovie = self.movie else { return }
        if currentMovie.favorite{
            addFavoriteButton.backgroundColor = .red
            addFavoriteButton.setTitle("💨Удалить из избранного💨", for: .normal)
        } else {
            addFavoriteButton.backgroundColor = UIColor(hex: "14D122")
            addFavoriteButton.setTitle("⭐️Добаить в избранное⭐️", for: .normal)
        }
    }

    @IBAction func addFavorite(_ sender: Any) {
        if let currentMovie = self.movie{
            DispatchQueue.main.async{
                let realm = try! Realm()
                try! realm.write{
                    currentMovie.favorite.toggle()
                    realm.add(currentMovie, update: true)
                    self.updateFavoriteButton()
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("updateCellMovie"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("updateFavorites"), object: nil)
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return self.tableView.frame.width/CGFloat(1/1.5)
        } else {
            return UITableView.automaticDimension
        }
    }


}

