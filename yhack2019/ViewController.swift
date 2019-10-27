//
//  ViewController.swift
//  yhack2019
//
//  Created by Yuanyuting Wang on 10/26/19.
//  Copyright © 2019 rawe. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var userInputText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInputTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        printMessagesForUser(input: textField.text!, completion: changeLabel(input:))
    }
    
    private func changeLabel(input: String) {
        userInputText.text = input
    }
    
    // eventually, this sends user input to Python and get the video url back
    private func printMessagesForUser(input: String, completion: @escaping(String) -> Void) {
        let json = ["message":input]
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
                    
                    // retrieving video from firebase and showing on screen
                    
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
    
    //MARK: Action
   
    // touch up on the button triggers a media picker
    @IBAction func selectVideo(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // the selected video is stored in firebase
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let videoURL = info[UIImagePickerController.InfoKey.imageURL] as?
            NSURL else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        let storageReference = Storage.storage().reference().child(videoURL.lastPathComponent!)

        storageReference.putFile(from: videoURL as URL, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                print("Successful video upload")
                // some kind of success message is supposed to be shown on the page here
            } else {
                print(error?.localizedDescription ?? "can't load error")
            }
        })
        dismiss(animated: true, completion: nil)
    }
    
}

