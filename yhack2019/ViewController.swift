//
//  ViewController.swift
//  yhack2019
//
//  Created by Yuanyuting Wang on 10/26/19.
//  Copyright © 2019 rawe. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var sendVideoPreview: UIImageView!
    @IBOutlet weak var userInputTextField: UITextField!

    var curVideoURL: NSURL? {
        didSet {
            sendVideoPreview.image = videoSnapshot(videoURL: curVideoURL!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInputTextField.delegate = self
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc func respondToSwipeGesture() {
        print("swiped left")
        self.performSegue(withIdentifier: "idSegue", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        printMessagesForUser(domain: "Message", input: ["message": textField.text!], completion: printCompletion(input:))
    }
    
    private func printCompletion(input: String) {
        print("successfully got message from backend: \(input)")
    }
    
    // eventually, this sends user input to Python and get the video url back
    private func printMessagesForUser(domain: String, input: [String: String], completion: @escaping(String) -> Void?) {
        let json = input
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let url = NSURL(string: "http://127.0.0.1:5000/\(domain)/")!
            
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
    @IBAction func sendVideo(_ sender: UIButton) {
        let storageReference = Storage.storage().reference().child(curVideoURL!.lastPathComponent!)
        
        storageReference.putFile(from: curVideoURL! as URL, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                print("Successful video upload")
                // some kind of success message is supposed to be shown on the page here
            } else {
                print(error?.localizedDescription ?? "can't load error")
            }
        })
        
        printMessagesForUser(domain: "Video", input: ["url": curVideoURL!.absoluteString!, "name": curVideoURL!.lastPathComponent!], completion: printCompletion(input:))
        let bundle = Bundle(for: type(of: self))
        sendVideoPreview.image = UIImage(named: "defaultPhoto", in: bundle, compatibleWith: self.traitCollection)
        userInputTextField.text = ""
        
        let alertController = UIAlertController(title: "Video successfully sent~", message:
            "Thank you for making another person feel better today!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Done", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // touch up on the button triggers a media picker
    @IBAction func selectVideo(_ sender: UIButton) {
        userInputTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func videoSnapshot(videoURL: NSURL) -> UIImage? {
        
        let asset = AVURLAsset(url: videoURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 60), actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        else {
            return nil
        }
    }
    
    // the selected video is stored in firebase
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as?
            NSURL else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        curVideoURL = videoURL
        
        dismiss(animated: true, completion: nil)
    }
    
}

