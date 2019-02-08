//
//  ChooseCategories.swift
//  FeedImages
//
//  Created by carloshenrique.carmo on 07/02/19.
//  Copyright © 2019 carloshpdoc. All rights reserved.
//

import UIKit

class ChooseCategories: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var categories = ["Airplanes", "Beaches", "Bridges", "Cats", "Cities", "Dogs", "Earth", "Forests", "Galaxies", "Landmarks", "Mountains", "People", "Roads", "Sports", "Sunsets"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Images") as? ImagesVC else { return }
        
        vc.category = categories[indexPath.row]
        
        present(vc, animated: true)
    }
    
}
