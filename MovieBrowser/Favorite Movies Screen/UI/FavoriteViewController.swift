//
//  FavoriteViewController.swift
//  MovieBrowser
//
//  Created by Евгений on 29.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies = [Movie]() { didSet { tableView.reloadData() } }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        movies = Array(realm.objects(Movie.self).filter("favorite = true"))
         NotificationCenter.default.addObserver(self, selector: #selector(self.updateFavorites(_:)), name: NSNotification.Name(rawValue: "updateFavorites"), object: nil)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Search Cell", for: indexPath)
        if let movieCell = cell as? SearchCell{
            if movies.count >= indexPath.row{
                let movie = movies[indexPath.row]
                movieCell.posterImageView.image = UIImage(named: "defaultPostImage")
                movieCell.movie = movie
            }
        }
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Favorite"{
            if let indexPath = tableView.indexPathForSelectedRow{
                if let destinationVC = segue.destination as? MovieViewController{
                    let movie = movies[indexPath.row]
                    destinationVC.movie = movie
                    destinationVC.title = movie.title
                }
            }
        }
    }

    @objc func updateFavorites(_ notification: NSNotification?){
        let realm = try! Realm()
        movies = Array(realm.objects(Movie.self).filter("favorite = true"))
        tableView.reloadData()
    }
}

