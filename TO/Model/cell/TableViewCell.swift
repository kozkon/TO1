//
//  TableViewCell.swift
//  TO
//
//  Created by Константин Козлов on 15.03.2022.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    

    func setupCell(imageData: Data, text: String){
        
        cellImage.image = UIImage(data: imageData)
        cellImage.layer.cornerRadius = cellImage.frame.height / 5
        cellImage.clipsToBounds = true
        
        cellLabel.text = text
    }
    
}
