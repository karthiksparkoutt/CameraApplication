//
//  ImageViewController.swift
//  SampleProject
//
//  Created by Karthik Rajan T  on 14/09/20.
//  Copyright © 2020 Karthik Rajan T . All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    var getImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = getImage

    }
    
    @IBAction func tapOnDoneButton(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
          self.addChild(popOverVC)
          popOverVC.view.frame = self.view.frame
          self.view.addSubview(popOverVC.view)
          popOverVC.didMove(toParent: self)
    }
    

}
