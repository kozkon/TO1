//
//  ImageScrolVC.swift
//  TO
//
//  Created by Константин Козлов on 13.05.2022.
//

import UIKit

class ImageScrolVC: UIViewController {
    
    
     var image: Images!
    
    private var imageScrollView: ImageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView)
        setupImageScrollView()
        
        let image = UIImage(data: self.image.image!)
        self.imageScrollView.set(image: image!)
    }
    
    
    private func setupImageScrollView(){
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
