//
//  StartViewController.swift
//  DuckHuntAR
//
//  Created by Piyush Makwana on 31/03/19.
//  Copyright © 2019 Piyush Makwana. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var score: UILabel!
    @IBAction func Play(_ sender: Any) {
         performSegue(withIdentifier: "homeToGame", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let gameScore = defaults.value(forKey: "score"){
            let s = gameScore as! Int
            score.text = "\(String(s))"
        }
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
