//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

class Result : NSObject {
    dynamic var rank = 0
    dynamic var artistName = ""
    dynamic var trackName = ""
    dynamic var averageUserRating = 0.0
    dynamic var averageUserRatingForCurrentVersion = 0.0
    dynamic var itemDescription = ""
    dynamic var price = 0.00
    dynamic var releaseDate = NSDate()
    dynamic var artworkURL : URL?
    dynamic var artworkImage: UIImage?
    dynamic var screenShotURLs = [URL]()
    dynamic var screenShots = NSMutableArray()
    dynamic var userRatingCount = 0
    dynamic var userRatingCountForCurrentVersion = 0
    dynamic var primaryGenre = ""
    dynamic var fileSizeInBytes = 0
    dynamic var cellColor = UIColor.white()
    
    init(dictionary: NSDictionary) {
        artistName = dictionary["artistName"] as! String
        trackName = dictionary["trackName"] as! String
        itemDescription = dictionary["description"] as! String
        
        primaryGenre = dictionary["primaryGenreName"] as! String
        if let uRatingCount = dictionary["userRatingCount"] as? Int {
            userRatingCount = uRatingCount
        }
        
        if let uRatingCountForCurrentVersion = dictionary["userRatingCountForCurrentVersion"] as? Int {
            userRatingCountForCurrentVersion = uRatingCountForCurrentVersion
        }
        
        if let averageRating = (dictionary["averageUserRating"] as? Double) {
            averageUserRating = averageRating
        }
        
        if let averageRatingForCurrent = dictionary["averageUserRatingForCurrentVersion"] as? Double {
            averageUserRatingForCurrentVersion = averageRatingForCurrent
        }
        
        if let fileSize = dictionary["fileSizeBytes"] as? String {
            if let fileSizeInt = Int(fileSize) {
                fileSizeInBytes = fileSizeInt
            }
        }
        
        price = dictionary["price"]!.doubleValue
        let formatter = DateFormatter()
        let enUSPosixLocale = Locale(localeIdentifier: "en_US_POSIX")
        formatter.locale = enUSPosixLocale
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let releaseDateString = dictionary["releaseDate"] as? String {
            releaseDate = formatter.date(from: releaseDateString)!
        }
        if let artURL = URL(string: dictionary["artworkUrl512"] as! String) {
            artworkURL = artURL
        }
        
        if let screenShotsArray = dictionary["screenshotUrls"] as? [String] {
            for screenShotURLString in screenShotsArray {
                if let screenShotURL = URL(string: screenShotURLString) {
                    screenShotURLs.append(screenShotURL)
                }
            }
        }
        
        super.init()
    }
    
    func loadIcon() {
        if (artworkImage != nil) {
            return
        }
        
        iTunesRequestManager.downloadImage(imageURL: artworkURL!, completionHandler: { (image, error) -> Void in
            DispatchQueue.main.async() {
                self.artworkImage = image
            }
        })
    }
    
    func loadScreenShots() {
        if screenShots.count > 0 {
            return
        }
        
        for screenshotURL in screenShotURLs {
            iTunesRequestManager.downloadImage(imageURL: screenshotURL, completionHandler: { (image, error) -> Void in
                DispatchQueue.main.async() {
                    guard let image = image where error == nil else {
                        return;
                    }
                    
                    self.willChangeValue(forKey: "screenShots")
                    self.screenShots.add(image)
                    self.didChangeValue(forKey: "screenShots")
                }
                
            })
        }
    }
    
    override var description: String {
        get {
            return "artist: \(artistName) track: \(trackName) average rating: \(averageUserRating) price: \(price) release date: \(releaseDate)"
        }
    }
}

struct iTunesRequestManager {
    static func getSearchResults(query: String, results: Int, langString :String, completionHandler: (NSArray, NSError?) -> Void) {
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")
        let termQueryItem = URLQueryItem(name: "term", value: query)
        let limitQueryItem = URLQueryItem(name: "limit", value: "\(results)")
        let mediaQueryItem = URLQueryItem(name: "media", value: "software")
        urlComponents?.queryItems = [termQueryItem, mediaQueryItem, limitQueryItem]
        
        guard let url = urlComponents?.url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            do {
                let itunesData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let results = itunesData["results"] as? NSArray {
                    completionHandler(results, nil)
                } else {
                    completionHandler([], nil)
                }
            } catch _ {
                completionHandler([], error)
            }
            
        })
        task.resume()
    }
    
    static func downloadImage(imageURL: URL, completionHandler: (UIImage?, NSError?) -> Void) {
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let data = data where error == nil else {
                completionHandler(nil, error)
                return
            }
            let image = UIImage(data: data)
            completionHandler(image, nil)
        }
        task.resume()
    }
}

class ViewController : UITableViewController {
    var results = [Result]()
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        iTunesRequestManager.getSearchResults(query: "flappy", results: 5, langString: "en_us") { (results, error) in
            if (error != nil) {
                print(error)
            } else {
                let itunesResults = results.flatMap { $0 as? NSDictionary }
                    .map { return Result(dictionary: $0) }
                self.results = itunesResults
                
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        let result = results[indexPath.row]

        cell.textLabel?.text = result.trackName
        
        return cell
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true

let viewController = ViewController()
PlaygroundPage.current.liveView = viewController
