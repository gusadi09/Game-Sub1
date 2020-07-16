//
//  AboutViewController.swift
//  Game Sub
//
//  Created by Agus Adi Pranata on 17/07/20.
//  Copyright © 2020 gusadi. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var imageSelf: UIImageView!
    @IBOutlet weak var nameSelf: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageSelf.layer.borderWidth = 10.0
        imageSelf.layer.masksToBounds = false
        imageSelf.layer.borderColor = UIColor.black.cgColor
        imageSelf.layer.cornerRadius = imageSelf.frame.size.width/2
        imageSelf.clipsToBounds = true
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
