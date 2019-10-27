//
//  ViewController2.swift
//  yhack2019
//
//  Created by Yuanyuting Wang on 10/27/19.
//  Copyright © 2019 rawe. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

@IBDesignable
class ViewController2: UIViewController {
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        // Do any additional setup after loading the view.
        imageView.isHidden = true
        containerView.isHidden = true
    }
    
    private var isUserSubscribed = false {
        didSet {
            
            if isUserSubscribed {
                imageView.isHidden = true
            } else {
                imageView.isHidden = false
            }
        }
    }
    
    @objc func respondToSwipeGesture() {
        self.performSegue(withIdentifier: "idSegueBack", sender: self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        printMessagesForUser(domain: "Message", input: ["message": textField.text!], completion: getVideo(url:))
        textInput.text = ""
    }
    
    private func getVideo(url: String){
        let pathRef = Storage.storage().reference(withPath: url)
        let localURL = NSURL(string: "yhack2019/image/" + NSURL(string: url)?.lastPathComponent)
        
        let downloadTask = islandRef.write(toFile: localURL) { url, error in
            if let error = error {
               print("Error in downloading video!")
            }
        }
        
        let avPlayer = AVPlayer(playerItem: AVPlayerItem(url: localURL))
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = containerView.bounds
        containerView.layer.insertSublayer(avPlayerLayer, at: 0)
        containerView.isHidden = false
        
        imageView.image = videoSnapshot(videoURL: localURL)
        imageView.frame = containerView.frame
        containerView.addSubview(imageView)
        
        isUserSubscribed = true
        avPlayer.play()
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        isUserSubscribed = false
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
    
    private func printCompletion(input: String) {
        print("successfully got message from backend: \(input)")
    }
    
    // eventually, this sends user input to Python and get the video url back
    private func printMessagesForUser(domain: String, input: [String: String], completion: @escaping(String) -> Void?) {
        let json = input
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let url = NSURL(string: "http://127.0.0.1:5000/\(domain)")!
            
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
    
    
    

}
