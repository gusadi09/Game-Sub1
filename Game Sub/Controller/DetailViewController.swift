//
//  DetailViewController.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 17/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var ratingGame: UILabel!
    @IBOutlet weak var releaseGame: UILabel!
    @IBOutlet weak var genreGame: UILabel!
    
    @IBOutlet weak var descWrapView: UIView!
    @IBOutlet weak var releaseView: UIView!
    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var ratingView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descWrapView.layer.cornerRadius = 15
        releaseView.layer.cornerRadius = 5
        genreView.layer.cornerRadius = 10
        ratingView.layer.cornerRadius = 10
        
        gameImage.layer.cornerRadius = 20
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
