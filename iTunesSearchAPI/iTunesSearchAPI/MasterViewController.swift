//
//  MasterViewController.swift
//  iTunesSearchAPI
//  /Branch - feature
//  Created by Allan Villanueva on 8/18/19.
//  Copyright © 2019 Allan Villanueva. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    
    //Search details array
    //arrays that will store data parsed from JSON
    var trackNames = [String]()
    var ArtworkURL = [String]()
    var Price = [String]()
    var Genre = [String]()
    var Description = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Refresh screen when data from iTunes Search API is not yet loaded.
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadTableRows(_:)))
        navigationItem.rightBarButtonItem = refreshButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        parseJSONFromiTunesSearchAPI()
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func reloadTableRows(_ sender: Any) {
        self.tableView.reloadData()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                //Set detail view controller variables to selected row, indexed in an array of search details
                controller.detailName = trackNames[indexPath.row]
                controller.detailGenre = Genre[indexPath.row]
                controller.detailDescription = Description[indexPath.row]
                controller.detailArtworkURL = ArtworkURL[indexPath.row]
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                AppSettings.saveData(trackNames[indexPath.row], genre: Genre[indexPath.row], price: Price[indexPath.row], description: Description[indexPath.row], artworkURL: ArtworkURL[indexPath.row])
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return trackNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Set tableviewcell as custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellQueryList", for: indexPath) as! cellQueryList
        
        //Set cell objects from contents of search details array
        cell.lblTrackName!.text = trackNames[indexPath.row]
        cell.lblPrice!.text = "$\(Price[indexPath.row])"
        cell.lblGenre!.text = Genre[indexPath.row]
        cell.imgArtwork.imageFromURL(urlString: ArtworkURL[indexPath.row])
        
        print(trackNames[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func parseJSONFromiTunesSearchAPI() {
        
        //check valid URL
        guard let url = URL(string: "https://itunes.apple.com/search?term=star&amp;country=au&amp;media=movie&amp;all") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response error")
                return
            }
            do{
                //fetch data using JSON serialization
                let json = try JSONSerialization.jsonObject(with: dataResponse) as? [String:Any]
                
                //parse data as an array
                let fetchedArray = json!["results"] as? [[String:Any]]
                
                //fetch data as dictionary, loop until last item
                for dict in fetchedArray! {
                    //check parse object if valid else set default value
                    
                    if let trackname = dict["trackName"] as? String { // trackname
                        self.trackNames.append(trackname)
                    }
                    else {
                        self.trackNames.append("n/a")
                    }
                    
                    if let trackprice = dict["trackPrice"] as? Double { // price
                        self.Price.append("\(trackprice)")
                    }
                    else {
                        self.Price.append("0.00")
                    }
                    
                    if let trackgenre = dict["primaryGenreName"] as? String { // genre
                        self.Genre.append(trackgenre)
                    }
                    else {
                        self.Genre.append("n/a")
                    }
                    if let artworkurl = dict["artworkUrl100"] as? String { // artwork URL
                        self.ArtworkURL.append(artworkurl)
                    }
                    else {
                        self.ArtworkURL.append("")
                    }
                    if let longdescription = dict["longDescription"] as? String { // description
                        self.Description.append(longdescription)
                    }
                    else {
                        self.Description.append("Description not available.")
                    }
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()

    }
}

// Mark - UserDefaults - persistent data storage used
// for storing small amount data like arrays, values

struct AppSettings {
    
    static let (nameKey, genreKey, priceKey, descriptionKey, artworkURLKey) = ("name", "genre", "price", "description", "artworkURL")
    static let userSessionKey = "com.appetiser.iosapp.iTunesSearchAPI"
    
    struct Model {
        var name: String
        var genre: String
        var price: String
        var description: String
        var artworkURL: String
        
        //init variables as type:value pair
        init(_ json: [String: String]) {
            self.name = json[nameKey] ?? ""
            self.genre = json[genreKey] ?? ""
            self.price = json[priceKey] ?? ""
            self.description = json[descriptionKey] ?? ""
            self.artworkURL = json[artworkURLKey] ?? ""
        }
    }
    // save search details
    static func saveData(_ name: String, genre: String, price: String, description: String, artworkURL: String){
        UserDefaults.standard.set([nameKey: name, genreKey: genre, priceKey: price, descriptionKey: description, artworkURLKey: artworkURL], forKey: userSessionKey)
    }
    // fetch store search details
    static func getData()-> Model {
        return Model((UserDefaults.standard.value(forKey: userSessionKey) as? [String: String]) ?? [:])
    }
    // clear session data
    static func clearUserData(){
        UserDefaults.standard.removeObject(forKey: userSessionKey)
    }
}


// Mark - Extensions

//imageFromURL - used to set string URL directly from Imageview object
extension UIImageView {
    public func imageFromURL(urlString: String) {
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            
        }).resume()
    }
}

// Mark - Custom tableviewcell

class cellQueryList: UITableViewCell {
    
    @IBOutlet weak var imgArtwork: UIImageView!
    @IBOutlet weak var lblTrackName: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
}

