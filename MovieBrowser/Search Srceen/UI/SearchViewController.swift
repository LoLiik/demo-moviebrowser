//
//  SearchViewController.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

private let API_KEY = "0850a2ca8b5adfb48d45ad7084527caf"
fileprivate let SEARCH_URL = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&language=ru-RU&include_adult=false"
public let IMAGE_URL = "http://image.tmdb.org/t/p/"

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var movieSearchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    private let refreshControl = UIRefreshControl()

    // MARK: - Model
    var searchQuery: String = ""
    var movies: [Movie] = [Movie]()
    var totalPages: Int = 0
    var currentPage: Int = 0
    var rowBeforeSegue = -1 // Used for cell update after chenges on MovieViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableviewAppearence()
        setupRefresh()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCellMovie(_:)), name: NSNotification.Name(rawValue: "updateCellMovie"), object: nil)
    }

    private func setupTableviewAppearence(){
        tableView.tableFooterView = UIView()
        //        tableView.separatorStyle = .none
    }

    private func setupRefresh(){
        if #available(iOS 10.0, *){
            tableView.refreshControl = self.tableView.refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshMovies(_:)), for: .valueChanged)
    }

    @objc private func refreshMovies(_ sender: Any?){
        refreshControl.beginRefreshing()
        loadMovies{
            self.tableView.reloadData()
        }
    }

    func loadMovies(_ completion: @escaping () -> Void){
        var url = URLComponents(string: SEARCH_URL)
        var page: URLQueryItem = URLQueryItem(name: "page", value: "0")

        // MARK: - Padding is based on comparing current page with total pages count
        if currentPage == 0{
            page.value = "1"
        } else if currentPage < totalPages{
            page.value = "\(currentPage+1)"
        } else if currentPage == totalPages{
            return
        }
//        searchQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        // MARK: - Query construction
        let query = URLQueryItem(name: "query", value: searchQuery.trimmingCharacters(in: .whitespacesAndNewlines))
        url?.queryItems?.append(query)
        url?.queryItems?.append(page)
        guard let urlString = url?.string else {
            return
        }

        // MARK: - Alamofire request for movies
        let queue = DispatchQueue(label: "tmdb.test.api", qos: .background, attributes: .concurrent)
        Alamofire.request(urlString,
                          method: .get)
            .validate()
            .responseJSON(queue: queue){ response in
                guard response.result.isSuccess else {
                    // TODO: Get saved data From REALM
                    self.loadFromRealm()
                    print("Malformed data received from service")
                    print("Error while fetching posts: \(String(describing: response))")
                    return
                }

                guard let responseData = response.data else {
                    print("Malformed data received from service")
                    print("Error while fetching posts: \(String(describing: response))")
                    return
                }

                do {
                    // MARK: - Decode retrived data with JSONDecoder and assing type of [Providers] object
                    let parsedMovies = try JSONDecoder().decode(SearchResponse.self, from: responseData)
                    //MARK: - Get back to the main queue
                    self.movies.append(contentsOf: parsedMovies.movies)
                    
                    self.totalPages = parsedMovies.totalPages
                    self.currentPage = parsedMovies.currentPage
                    DispatchQueue.main.async {
                        let realm = try! Realm()
                        for movie in parsedMovies.movies{
                            movie.search = self.searchQuery
                            try! realm.write {
                                realm.add(movie, update: true)
                            }
                        }
                        completion()
                        self.refreshControl.endRefreshing()
                    }
                } catch let jsonError {
                    print(jsonError)
                    self.refreshControl.endRefreshing()
                }
        }
    }

    private func loadFromRealm(){
        DispatchQueue.main.async {
            let realm = try! Realm()
            self.movies = Array(realm.objects(Movie.self).filter("search = %@", self.searchQuery))
            self.tableView.reloadData()
        }
    }


    //MARK: - Adding swipe action for Favorites

    func contextualAddToFavoriteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let movie = self.movies[indexPath.row]
        let movieIsFavorite = movie.favorite
        let actionTitle = movieIsFavorite ? "💔" : "❤️"
        let action = UIContextualAction(style: .normal,
                                        title: actionTitle) {
                                            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let cell = self.tableView.cellForRow(at: indexPath) as? SearchCell
                                            DispatchQueue.main.async {
                                                let realm = try! Realm()
                                                try! realm.write {
                                                    movie.favorite = !movie.favorite
                                                    realm.add(movie, update: true)
                                                    //MARK: -  Update favorite image constraint
                                                    cell?.movie = movie
                                                }
                                            }
                                            completionHandler(true)
        }
        action.backgroundColor = movieIsFavorite ? UIColor.gray : UIColor.orange
        return action
    }

    @objc func updateCellMovie(_ notification: NSNotification?){
        if rowBeforeSegue >= 0{
            if let cell = tableView.cellForRow(at: IndexPath(row: rowBeforeSegue, section: 0)) as? SearchCell{
                cell.movie = movies[rowBeforeSegue]
            }
        }

    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == movieSearchTextField, let searchText = movieSearchTextField.text{
            if !searchText.isEmpty && searchQuery != searchText{
                movies.removeAll()
                self.tableView.reloadData()
                totalPages = 0
                currentPage = 0
                searchQuery = searchText
                movieSearchTextField.resignFirstResponder()
                self.title = "Результаты для \(searchQuery)"
                loadMovies {
                    self.tableView.reloadData()
                }
            }
        }
        return false
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Movie"{
            if let indexPath = tableView.indexPathForSelectedRow{
                rowBeforeSegue = indexPath.row
                if let destinationVC = segue.destination as? MovieViewController{
                    let movie = movies[indexPath.row]
                    destinationVC.movie = movie
                    destinationVC.title = movie.title
                }
            }
        }
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

        if indexPath.row == movies.count - 1 {
            refreshMovies(nil)
        }
        return cell

    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = self.contextualAddToFavoriteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [favoriteAction])
        return swipeConfig

    }

}
