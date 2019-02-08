//
//  ImagesVC.swift
//  FeedImages
//
//  Created by carloshenrique.carmo on 07/02/19.
//  Copyright © 2019 carloshpdoc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImagesVC: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var creditLabel: UILabel!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    var category = ""
    var appID = "6d7482cd6d2d509c1e0bbe367bc8e23ed7f17ddcbe8ae0895adce17e87149929"
    var images = [JSON]()
    var imageViews = [UIImageView]()
    var imageCounter = 0
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        imageViews = view.subviews.compactMap { $0 as? UIImageView }
        imageViews.forEach { $0.alpha = 0 }
        creditLabel.layer.cornerRadius = 15

        loadUnsplash()
    }
    
    func loadUnsplash () {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?client_id=\(appID)&query=\(category)&per_page=1") else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.fetch(url)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetch(_ url: URL) {
        
        if let data = try? Data(contentsOf: url) {
            
            let json = JSON(data)
            images = json["results"].arrayValue
            
            downloadImage()
        } else {
            showAlert( "Dismiss", message: "Not resolver data")
        }
    }
    
    func downloadImage() {

        //figure out what image to display
        let currentImage = images[imageCounter % images.count]
        
        //find its image URL and user credit
        let imageName = currentImage["urls"]["full"].stringValue
        let imageCredit = currentImage["user"]["name"].stringValue
        
        //add 1 to imageCounter so next time we load the following image
        imageCounter += 1
        
        //convert it to a Swift URL and download it
        guard let imageURL = URL(string: imageName) else { return }
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        //convert the Data to a UIImage
        guard let image = UIImage(data: imageData) else { return }
        
        //push our work to the mail thread
        DispatchQueue.main.async {
            
            self.show(image, credit: imageCredit)
        }
    }
    
    func show(_ image: UIImage, credit: String) {
        
        //stop the activity indicator animation
        spinner.stopAnimating()
        
        //figure out which image view to activate and deactivate
        let imageViewToUse = imageViews[imageCounter % imageViews.count]
        let otherImageView = imageViews[(imageCounter + 1) % imageViews.count]
        
        //start an animation over two seconds
        UIView.animate(withDuration: 2.0, animations: {
            
            //make the image view use our image, and alpha it up to 1
            imageViewToUse.image = image
            imageViewToUse.alpha = 1
            
            //fade out the credit label to avoid it looking wrong
            self.creditLabel.alpha = 0
            
            //move the deactivated image to the back, behind the activated one
            self.view.sendSubviewToBack(otherImageView)
            
        }) { _ in
            
            //crossfade finished
            self.creditLabel.text = "  \(credit.uppercased())"
            self.creditLabel.alpha = 1
            otherImageView.alpha = 0
            
            otherImageView.transform = .identity
            
            UIView.animate(withDuration: 10.0, animations: {
                
                imageViewToUse.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) {
                _ in
                
                DispatchQueue.global(qos: .userInteractive).async {
                    
                    self.downloadImage()
                }
                
            }
            
        }
    }
}
