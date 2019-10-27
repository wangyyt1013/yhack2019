//
//  swipeSegue.swift
//  yhack2019
//
//  Created by Yuanyuting Wang on 10/27/19.
//  Copyright © 2019 rawe. All rights reserved.
//

import UIKit

class swipeSegue: UIStoryboardSegue {

    override func perform() {
        // Assign the source and destination views to local variables.
        var firstVCView = self.source.view as UIView
        var secondVCView = self.destination.view as UIView
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        secondVCView.frame = CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: screenHeight)
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            firstVCView.frame.offsetBy(dx: 0.0, dy: -screenHeight)
            secondVCView.frame.offsetBy(dx: 0.0, dy: -screenHeight)
            
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController,
                animated: false, completion: nil)
        }
    }
    
}
