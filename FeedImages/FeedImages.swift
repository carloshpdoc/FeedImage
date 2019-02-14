//
//  FeedImages.swift
//  FeedImages
//
//  Created by carloshenrique.carmo on 12/02/19.
//  Copyright © 2019 carloshpdoc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FeedImages: UIViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var creditLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
    
    var category:String = ""
    var images:[Image] = []
    var imageCounter = 0
    
    
    override func viewDidLoad() {
        
        //        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        //        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //        let predicate = NSPredicate(format: "category = %@", category)
        //        fetchRequest.predicate = predicate
        //        fetchRequest.sortDescriptors = [sortDescriptor]
        getUnsplash()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func getUnsplash() {
        ImagesVC.sharedInstance.getUnsplash(category) { (success, unsplash, error) in
            
            if !success {
                // Show Alert
                self.showAlert(nil, message: error!)
                print(error!)
                return
            }
            
            unsplash!.results.forEach() { result in
                let image = Image(context: self.dataController.viewContext)
                image.url = URL(string: result.urls.small)?.absoluteString
                image.caption = result.user.name
                image.creationDate =  Date()
                image.category = self.category
                
                do {
                    // Saves to CoreData
                    try self.dataController.viewContext.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
            self.downloadImage()
        }
    }
    
    func downloadImage(imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void) {
        
        // Create session and request
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        // Create network request
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, downloadError in
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
    func downloadImage() {

        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        let predicate = NSPredicate(format: "category = %@", category)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            images = result
        }
        
        // figure out what image to display
        let currentImage = images[imageCounter % images.count]
        
        //find its image URL and user credit
        let imageName = currentImage.url
        let imageCredit = currentImage.caption
        
        //add 1 to imageCounter so next time we load the following image
        imageCounter += 1
        
        //convert it to a Swift URL and download it
        guard let imageURL = URL(string: imageName!) else { return }
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        //convert the Data to a UIImage
        guard let image = UIImage(data: imageData) else { return }
        
        //push our work to the mail thread
        DispatchQueue.main.async {
            
            self.show(image, imageCredit!)
        }
    }
    
    func show(_ image: UIImage, _ credit: String) {
        
        //stop the activity indicator animation
        spinner.stopAnimating()
        
        //figure out which image view to activate and deactivate
        let imageViewToUse = imageViews[imageCounter % imageViews.count]
        let otherImageView = imageViews[(imageCounter + 1) % imageViews.count]
        
        //            start an animation over two seconds
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
