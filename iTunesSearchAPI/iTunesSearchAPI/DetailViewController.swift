//
//  DetailViewController.swift
//  iTunesSearchAPI
//
//  Created by Allan Villanueva on 8/18/19.
//  Copyright © 2019 Allan Villanueva. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imgArtwork: UIImageView!
    @IBOutlet weak var lblTrackName: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    

    func configureView() {
        // Update the user interface for the detail item.
        if let track = detailName {
            if let label = lblTrackName {
                label.text = track.description
            }
        }
        
        if let genre = detailGenre {
            if let label = lblGenre {
                label.text = genre.description
            }
        }
        if let url = detailArtworkURL {
            if let img = imgArtwork {
                img.imageFromURL(urlString: url.description)
            }
        }
        
        if let description = detailDescription {
            if let label = lblDescription {
                label.text = description.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailName: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    var detailGenre: String?
    var detailDescription: String?
    var detailArtworkURL: String?
}

