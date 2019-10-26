//
//  ViewController.swift
//  yhack2019
//
//  Created by Yuanyuting Wang on 10/26/19.
//  Copyright © 2019 rawe. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textView.delegate = self
        print("--------------------------")
        printMessagesForUser(completion: changeTextView(input:))
        print("Please just print something")
    }
    private func changeTextView(input: String) {
        textView.text = input
    }
    private func printMessagesForUser(completion: @escaping(String) -> Void) {
        let json = ["user":"larry"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let url = NSURL(string: "http://127.0.0.1:5000/")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            
            request.setValue("application/json; charset=utf-8",forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
     
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                if error != nil{
                    print("Error -> \(String(describing: error))")
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
                    print ("Result -> \(String(describing: result))")
                    completion("Result -> \(String(describing: result))")
                } catch {
                    completion("Error -> \(error)")
                }
            }
            task.resume()
        } catch {
            print(error)
        }
    }


}

