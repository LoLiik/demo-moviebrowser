# demo-moviebrowser
First MVP for TMDB Movie Browser App

Realm & Alamofire applied. 
RxSwift - next.

What is  done:
- Movie list in SearchViewController with padding (downloaded from tmdb.org)
- Detailed movie information in MovieViewController (segue by tap at SearchViewController row)
- Movie added to Favorites with swipe on SearchTableView or with button pressed in MovieViewController
- Favorite Movies showed in FavoriteViewController (showed by TabBar Favorite item)
- add image saving at local bundle and loads if accessible

Scheduled improvments:
- improve favorite updates
- implement MVVM (binding by RxSwift)
- refactor
