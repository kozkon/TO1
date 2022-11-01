//
//  EditPhotoVC.swift
//  TO
//
//  Created by Константин Козлов on 02.02.2022.
//

import UIKit

class EditPhotoVC: UIViewController {
    
    var image: Images!
    var photo: Photo!
    var shopName: String!
    private var dataStoreManager = DataStoreManager()
    private var imagePhoto: UIImage!
    var indexImage: IndexPath!
 
    
    @IBOutlet weak var imageView: UIImageView!
    
  
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        let photos = self.dataStoreManager.fetchPhotoFromShop(shopName: self.shopName)
        guard let photo = photos.filter({ $0.object == self.photo.object
        }).first else {return}
        
        let images = self.dataStoreManager.fetchImagesFromPhoto(photo: photo)
        let imageToDelete = images[indexImage.row]
        self.dataStoreManager.deleteDataObject(object: imageToDelete)
        
        
        let context = self.dataStoreManager.viewContext
        
        

        
        guard let imageObject = self.dataStoreManager.createImage(with: context) else {return}
        
        guard let imageForSave = self.imageView.image else {return}
        
     
        
        imageObject.image = imageForSave.jpegData(compressionQuality: 0)
        
        photo.object = self.photo.object
        
        photo.addToImages(imageObject)
        
        do{
            try context.save()
            
            let ac = UIAlertController(title: "Поворот фотографии сохранен", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            ac.addAction(okAction)
            present(ac, animated: true)
        }catch let error{
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func leftRotateButton(_ sender: UIButton) {
        
        switch self.imageView.image?.imageOrientation {
        case .left:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .down)
        case .down:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .right)
        case .right:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .up)
        case .up:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .left)
        default:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .left)
        }
        
        image.image = imageView.image?.jpegData(compressionQuality: 1)
        
 
    }
    
    @IBAction func rightRotateButton(_ sender: UIButton) {
        switch self.imageView.image?.imageOrientation {
        case .left:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .up)
        case .up:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .right)
        case .right:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .down)
        case .down:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .left)
        default:
            imageView.image = UIImage(cgImage: (UIImage(data: image.image!)?.cgImage)!, scale: 1.0, orientation: .left)
        }
        
        image.image = imageView.image?.jpegData(compressionQuality: 1)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView.image = UIImage(data: image.image!)
    
        addGesture()
    }
    
    
    private func addGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditPhotoVC.tappedMe))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
    }
    
    
    @objc func tappedMe() {
        performSegue(withIdentifier: "toScrollVC", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScrollVC" {
            guard let imagePhoto = segue.destination as? ImageScrolVC else {return}
            imagePhoto.image = self.image
        }
    }
}
