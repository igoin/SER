//
//  serViewController.swift
//  SER
//
//  Created by Dongkyu Lee on 2017. 6. 12..
//  Copyright © 2017년 Dongkyu Lee. All rights reserved.
//

import UIKit

class SerViewController: UIViewController{
    
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeButton.layer.cornerRadius = 10
        self.emotionLabel.layer.cornerRadius = 125
        emotionLabel.text = "You Are Happy"
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}
