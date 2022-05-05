//
//  InfoViewController.swift
//  Hamaniec
//
//  Created by Ales Krot on 2.05.22.
//

import UIKit
import CoreData

class InfoViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoImage: UIImageView!
    private var whiteColorTextViewController = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    private var backgroundColorViewController = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareColorsInfoVC()
    }
    
    private func prepareColorsInfoVC() {
        self.view.backgroundColor = backgroundColorViewController
        infoLabel.textColor = whiteColorTextViewController
        self.title = "Developer"
        infoImage.layer.cornerRadius = infoImage.frame.size.width / 2
    }
    @IBAction func didTapLinkedInButton(_ sender: UIButton) {
        let stringToURL = "https://www.linkedin.com/in/aleskrot/"
        let _ = URL(string: stringToURL)
    }
}
