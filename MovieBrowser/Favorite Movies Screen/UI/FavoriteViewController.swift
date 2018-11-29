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
        print(movies)
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
}
