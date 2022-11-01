//
//  PhotoDescriptionVC.swift
//  TO
//
//  Created by Константин Козлов on 27.01.2022.
//

import UIKit
import PhotosUI

class PhotoDescriptionVC: UIViewController {
    
    var photo: Photo!
    var image: Images!
    private var images: [Images]!
    private var photos: [Photo]!
    var shopName: String!
    private var imagesCount: Int!
    private var dataStoreManager = DataStoreManager()
    var indexImage: IndexPath!
    
    @IBOutlet weak var desctiptionLabel: UILabel!
    @IBOutlet weak var namePhotoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Добить изображение", message: "Добавьте существующее или сделайте новое фото", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Сделать снимок", style: .default) { action in
            self.chooseImagePecker(source: .camera)
        }
        let imageCamera = UIImage(named: "cameraAlert")
        cameraAction.setValue(imageCamera, forKey: "image")
        
        let mediaAction = UIAlertAction(title: "Медиатека", style: .default) { _ in
            if #available(iOS 14, *) {
                self.choosePHPiecker()
            } else {
                self.chooseImagePecker(source: .photoLibrary)
            }
        }
        let imageMedia = UIImage(named: "mediaAlert")
        mediaAction.setValue(imageMedia, forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        ac.addAction(cameraAction)
        ac.addAction(mediaAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        getImagesCount()
        desctiptionLabel.text = photo.descriptions
        namePhotoLabel.text = photo.object
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private func getImagesCount(){
        
        let photos = dataStoreManager.fetchPhotoFromShop(shopName: shopName)
        self.photo = photos.filter{ $0.object == photo.object
        }.first
        self.images = dataStoreManager.fetchImagesFromPhoto(photo: self.photo)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditPhotoVC" {
            guard let editPhoto = segue.destination as? EditPhotoVC else {return}
            editPhoto.image = self.image
            editPhoto.photo = self.photo
            editPhoto.shopName = self.shopName
            editPhoto.indexImage = self.indexImage
        }
    }
    
    private func resizeImage(image: UIImage) -> UIImage {
         let size = image.size
         
        let widthRatio  =  0.5
        let heightRatio = 0.5
         
         // Figure out what our orientation is, and use that to form the rectangle
         var newSize: CGSize
         if(widthRatio > heightRatio) {
             newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
         } else {
             newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
         }
         
         // This is the rect that we've calculated out and this is what is actually used below
         let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
         
         // Actually do the resizing to the rect using the ImageContext stuff
         UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
         image.draw(in: rect)
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         
         return newImage!
     }
}


//MARK: UITableViewDelegate

extension PhotoDescriptionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _, _, completionHandler in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                let photos = self.dataStoreManager.fetchPhotoFromShop(shopName: self.shopName)
                guard let photo = photos.filter({ $0.object == self.photo.object
                }).first else {return}
                
                let images = self.dataStoreManager.fetchImagesFromPhoto(photo: photo)
                let imageToDelete = images[indexPath.row]
                self.dataStoreManager.deleteDataObject(object: imageToDelete)
                
                self.images.remove(at: indexPath.row)
                
                if #available(iOS 13.0, *) {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.reloadData()
                }
                
              self.getImagesCount()
            }
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}


//MARK: UITableViewDataSource

extension PhotoDescriptionVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return images.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell {
            
            guard let imageData = images[indexPath.row].image else {return cell}
            
            let text: String!
            
            if self.images.count > 1{
                text = "\(photo.object ?? "")_\(indexPath.row + 1)"
            }else{
                text = photo.object
            }
            
            cell.setupCell(imageData: imageData, text: text)
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.indexImage = indexPath
        self.image = self.images[indexPath.row]
        performSegue(withIdentifier: "toEditPhotoVC", sender: nil)
    }
}

//MARK: PHPickerViewControllerDelegate

@available(iOS 14, *)
extension PhotoDescriptionVC: PHPickerViewControllerDelegate {
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        dismiss(animated: true) {
            self.getImagesCount()
            self.tableView.reloadData()
        }
        
        for item in results {
            
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    
                    DispatchQueue.main.async {
                        
                        let context = self.dataStoreManager.viewContext
                        
                        let photos = self.dataStoreManager.fetchPhotoFromShop(shopName: self.shopName)
                        let photo = photos.filter{ $0.object == self.photo.object
                        }.first
                        
                        guard let imageObject = self.dataStoreManager.createImage(with: context) else {return}
                        
                        let imageForSave = self.resizeImage(image: image)
                        
                        imageObject.image = imageForSave.jpegData(compressionQuality: 0)
                        
                        photo?.object = self.photo.object
                        
                        photo?.addToImages(imageObject)
                        
                        do{
                            try context.save()
                        }catch let error{
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func choosePHPiecker(){
        var configPHPiecker = PHPickerConfiguration()
        configPHPiecker.filter = .images
        configPHPiecker.selectionLimit = 10
        
        let picker = PHPickerViewController(configuration: configPHPiecker)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}


//MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PhotoDescriptionVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private func chooseImagePecker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        } else{
            UIAlertController(title: "iOSDevCenter", message: "No Camera available.", preferredStyle: .alert).show(self, sender: nil);
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.main.async {
            
            let context = self.dataStoreManager.viewContext
            
            let photos = self.dataStoreManager.fetchPhotoFromShop(shopName: self.shopName)
            let photo = photos.filter{ $0.object == self.photo.object
            }.first
            
            guard let imageObject = self.dataStoreManager.createImage(with: context) else {return}
            
            guard let image = info[.originalImage] as? UIImage else {return}
            let imageForSave = self.resizeImage(image: image)
            imageObject.image = imageForSave.jpegData(compressionQuality: 1)
            
            photo?.object = self.photo.object
            
            photo?.addToImages(imageObject)
            
            do{
                try context.save()
            }catch let error{
                print(error.localizedDescription)
            }
            self.getImagesCount()
            self.tableView.reloadData()
        }
        dismiss(animated: true)
    }
}

