//
//  SearchViewController.swift
//  MovieBrowser
//
//  Created by Евгений on 28.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit
import Alamofire

private let API_KEY = "0850a2ca8b5adfb48d45ad7084527caf"
fileprivate let SEARCH_URL = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&language=ru-RU&include_adult=false"
public let IMAGE_URL = "http://image.tmdb.org/t/p/original"

class SearchTableViewController: UITableViewController{

    var searchQuery: String = ""
    var movies: [Movie] = [Movie]()
    var totalPages: Int = 0
    var currentPage: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        loadMovies {
            self.tableView.reloadData()
        }

    }

    func loadMovies(_ completion: @escaping () -> Void){
        var url = URLComponents(string: SEARCH_URL)
        var page: URLQueryItem = URLQueryItem(name: "page", value: "0")

        // MARK: - Padding is based on current and total page comparing
        if currentPage == 0{
            page.value = "1"
        } else if currentPage < totalPages{
            page.value = "\(currentPage+1)"
        } else if currentPage == totalPages{
            return
        }

        // MARK: - Query construction
        let query = URLQueryItem(name: "query", value: "RUS")
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
                    let parsedMovies = try JSONDecoder().decode(MovieResponse.self, from: responseData)

                    //MARK: - Get back to the main queue
                    self.movies.append(contentsOf: parsedMovies.movies)
                    self.totalPages = parsedMovies.totalPages
                    self.currentPage = parsedMovies.currentPage
                    DispatchQueue.main.async {
                        completion()
                    }
                } catch let jsonError {
                    print(jsonError)
                }
        }
    }


    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchCell", for: indexPath)
        if let movieCell = cell as? MovieSearchTableViewCell{
            if movies.count >= indexPath.row{
                movieCell.movie = movies[indexPath.row] as? Movie
            }
        }

        if indexPath.row == movies.count - 1 {
            loadMovies{
                self.tableView.reloadData()
            }
        }
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMovie"{
            if let indexPath = tableView.indexPathForSelectedRow{
                if let destinationVC = segue.destination as? MovieViewController{
                    destinationVC.movie = movies[indexPath.row]
                    destinationVC.title = movies[indexPath.row].title
                }
            }
        }
    }


}
