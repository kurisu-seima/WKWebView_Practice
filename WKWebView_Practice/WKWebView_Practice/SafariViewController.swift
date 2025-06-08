//
//  SafariViewController.swift
//  WKWebView_Practice
//
//  Created by 栗須　星舞 on 2025/06/08.
//

import UIKit
import SafariServices

class SafariViewController: UIViewController {
    
    private let url = URL(string: "https://www.google.co.jp")!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func safariButtonDidTap(_ sender: Any) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .fullScreen
        present(safariVC, animated: true)
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
