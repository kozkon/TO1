//
//  TableOfPhotoVC.swift
//  TO
//
//  Created by Константин Козлов on 17.01.2022.
//

import UIKit
import CoreData

class TableOfPhotoVC: UIViewController {
    
    private var arrayPhoto: [Photo]!
    var arrayOfDictionaryPhoto: Array<[String: AnyObject]>! //массив всех фото
    var photo: Photo!
    var filteredPhoto: [Photo]!
    private var currentSegmentOfTypePhoto = "uks"
    var shopName: String!
    private var dataStoreManager = DataStoreManager()
    var shop: Shop!
    private let slider = UISlider()
    private var sliderValueForLabel: Int!
    private let compressionLabel = UILabel()
    private var compressionLevel: CGFloat = 0.99
    private let countImagesLabel = UILabel()
    private let currentCountImagesLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    private var countImagesCreated = 0
    var cashCount: Int = 2
    var TDCount: Int = 2
    var TSDCount: Int = 2
    var MPCount: Int = 1
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        guard let name = shopName else {return}
        switch sender.selectedSegmentIndex {
        case 0:
            self.currentSegmentOfTypePhoto = "uks"
            self.title = "\(name) ( УКС)"
            filterContentForSearchText(self.currentSegmentOfTypePhoto)
        case 1:
            self.currentSegmentOfTypePhoto = "cash"
            self.title = "\(name) ( кассы)"
            filterContentForSearchText(self.currentSegmentOfTypePhoto)
        case 2:
            self.title = "\(name) ( прочее)"
            self.currentSegmentOfTypePhoto = "other"
            filterContentForSearchText(self.currentSegmentOfTypePhoto)
        default:
            self.title = "Фотоотчет "
            
        }
    }
    
    
    @objc func sliderDidEndSliding(notification: NSNotification)
    {
        
        let val = CGFloat(Int(slider.value))
        compressionLabel.text = "\(String(Int(val))) %"
        compressionLevel = (100 - val) / 100
    }
    
    
    @IBAction func actionForTO(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Выберете степень сжатия сохраняемых фото", message: "После сохранения фото будут доступны из приложения Файлы вашего IPhone", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { _ in
            
            self.createFiles()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        ac.addAction(saveAction)
        ac.addAction(cancelAction)
        
        // now create our custom view - we are using a container view which can contain other views
        let containerViewWidth = 250
        let containerViewHeight = 80
        let containerFrame = CGRect(x:10, y: 100, width: CGFloat(containerViewWidth), height: CGFloat(containerViewHeight))
        let containerView: UIView = UIView(frame: containerFrame)
        
        ac.view.addSubview(containerView)
        
        //  now add some constraints to make sure that the alert resizes itself
        let cons:NSLayoutConstraint = NSLayoutConstraint(item: ac.view as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: containerView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.00, constant: 160)
        
        ac.view.addConstraint(cons)
        
        let cons2:NSLayoutConstraint = NSLayoutConstraint(item: ac.view as Any, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: containerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.00, constant: 20)
        
        ac.view.addConstraint(cons2)
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        
        containerView.addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            slider.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            slider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        ])
        
        slider.addTarget(self, action: #selector(self.sliderDidEndSliding(notification:)), for: [.touchDragInside])
        
        compressionLabel.text = "0 %"
        compressionLabel.textAlignment = .center
        containerView.addSubview(compressionLabel)
        
        compressionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compressionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            compressionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            compressionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        present(ac, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        
        title = "\(shopName!) ( УКС)"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        checkDataExistence()
        filterContentForSearchText(self.currentSegmentOfTypePhoto)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.checkDataExistence()
            self.filterContentForSearchText(self.currentSegmentOfTypePhoto)
            self.tableView.reloadData()
        }
    }
    
    
    private func addPhotoToShop(){
        
        shop = dataStoreManager.fetchShop(name: self.shopName).first
        let context = dataStoreManager.viewContext
        
        for photoItem in arrayOfDictionaryPhoto{
            
            guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {return}
            guard let photo = NSManagedObject(entity: entity, insertInto: context) as? Photo else {return}
            
            photo.object = photoItem["object"] as? String
            photo.nameForReport = photoItem["nameForReport"] as? String
            photo.descriptions = photoItem["description"] as? String
            photo.kit = photoItem["kit"] as? String
            
            guard let entity = NSEntityDescription.entity(forEntityName: "Images", in: context) else {return}
            guard let image = NSManagedObject(entity: entity, insertInto: context) as? Images else {return}
            guard let imageData = Optional(Data()) else {return}
            
            image.image = imageData
            
            
            shop.addToPhoto(photo)
            do{
                try context.save()
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoDescriptionVC" {
            guard let photoDescription = segue.destination as? PhotoDescriptionVC else {return}
            photoDescription.photo = self.photo
            photoDescription.shopName = shopName
        }
    }
    
    
    private func checkDataExistence(){
        
        if dataStoreManager.fetchShop(name: shopName).isEmpty {
            
            saveShop()
            addPhotoToShop()
            arrayPhoto = dataStoreManager.fetchPhotoFromShop(shopName: shopName)
        }else{
            arrayPhoto = dataStoreManager.fetchPhotoFromShop(shopName: shopName)
        }
    }
    
    
    private func saveShop(){
        let context = dataStoreManager.viewContext
        
        guard let shopName = self.shopName else {return}
        dataStoreManager.saveShop(with: context, name: shopName)
    }
    
    
    private func filterContentForSearchText(_ searchText: String){
        
        var kitPhoto: [Photo]!
        
        if searchText == "other"{
            
            kitPhoto = arrayPhoto.filter({ ($0.kit == searchText)})
            kitPhoto += arrayPhoto.filter({ ($0.kit == "td")})
            kitPhoto += arrayPhoto.filter({ ($0.kit == "tsd")})
            kitPhoto += arrayPhoto.filter({ ($0.kit == "mp")})
            
        }else{
            kitPhoto = arrayPhoto.filter({ ($0.kit == searchText)})
        }
        self.filteredPhoto = kitPhoto
        tableView.reloadData()
    }
}

//MARK: FileManager
extension TableOfPhotoVC {
    private func createFiles(){
        
        let izLabel = UILabel()
        self.currentCountImagesLabel.setNeedsDisplay()
        
        self.fetchCountInImagesInShop(label: countImagesLabel)
        
        izLabel.text = "из"
        
        let ac = UIAlertController(title: "Сохранение фото", message: "Сохранено фото:", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { _ in
            
            self.showFinalAlert()
        }
        
        // now create our custom view - we are using a container view which can contain other views
        let containerViewWidth = 250
        let containerViewHeight = 150
        let containerFrame = CGRect(x:10, y: 100, width: CGFloat(containerViewWidth), height: CGFloat(containerViewHeight))
        let containerView: UIView = UIView(frame: containerFrame)
        
        ac.view.addSubview(containerView)
        
        //  now add some constraints to make sure that the alert resizes itself
        let cons:NSLayoutConstraint = NSLayoutConstraint(item: ac.view as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: containerView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.00, constant: 150)
        
        ac.view.addConstraint(cons)
        
        let cons2:NSLayoutConstraint = NSLayoutConstraint(item: ac.view as Any, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: containerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.00, constant: 0)
        
        ac.view.addConstraint(cons2)
        
        containerView.addSubview(self.countImagesLabel)
        containerView.addSubview(self.currentCountImagesLabel)
        containerView.addSubview(izLabel)
        containerView.addSubview(activityIndicator)
        
        self.countImagesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.currentCountImagesLabel.translatesAutoresizingMaskIntoConstraints = false
        izLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        self.countImagesLabel.font = UIFont.systemFont(ofSize: 25)
        self.currentCountImagesLabel.font = UIFont.systemFont(ofSize: 25)
        izLabel.font = UIFont.systemFont(ofSize: 25)
        
        
        NSLayoutConstraint.activate([
            self.countImagesLabel.leadingAnchor.constraint(equalTo: izLabel.leadingAnchor, constant: 40),
            self.countImagesLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            currentCountImagesLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            currentCountImagesLabel.trailingAnchor.constraint(equalTo: izLabel.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            izLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            izLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20)
            
        ])
        
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            // Fallback on earlier versions
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        
        containerView.layoutSubviews()
        activityIndicator.startAnimating()
        self.compressionLabel.textAlignment = .center
        
        ac.addAction(saveAction)
        
        present(ac, animated: true)
        
        DispatchQueue.global().async {
            
            self.fetchArrayPhotoForFiles()
        }
    }
    
    
    private func showFinalAlert(){
        
        let ac = UIAlertController(title: "Фото сформированы", message: "Теперь перейдите в приложение Файлы и сожмите созданную папку с фото в архив", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        
        ac.addAction(okAction)
        
        present(ac, animated: true)
    }
    
    
    private func fetchCountInImagesInShop(label: UILabel){
        
        var imagesCount = [Images]()
        
        let photoArray = dataStoreManager.fetchPhotoFromShop(shopName: shopName)
        
        for photo in photoArray {
            
            imagesCount += dataStoreManager.fetchImagesFromPhoto(photo: photo)
        }
        
        label.text = String(imagesCount.count)
    }
    
    
    private func fetchArrayPhotoForFiles(){
        
        let fileManager = FileManager.default
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let shopFolder = url.appendingPathComponent(shopName)
        let shopFolderKE = shopFolder.appendingPathComponent("KE")
        
        do{
            try fileManager.createDirectory(at: shopFolderKE, withIntermediateDirectories: true)
        }catch{
            print(error)
        }
        
        let photoArray = dataStoreManager.fetchPhotoFromShop(shopName: shopName)
        let photoUks = photoArray.filter ({ ($0.kit == "uks") })
        let photoUksKE = photoUks.filter { $0.object?.contains("KE") ?? false }
        let photoUksWithoutKE = Array(Set(photoUks).subtracting(photoUksKE))
        saveImageFromPhotoArray(array: photoUksKE, url: shopFolderKE)
        saveImageFromPhotoArray(array: photoUksWithoutKE, url: shopFolder)
        
        var arrayCashPhoto = photoArray.filter({$0.kit == "cash"})
        arrayCashPhoto = arrayCashPhoto.map({ photo in
            let newPhoto = photo
            let cashPref = photo.object?.prefix(7)
            
            newPhoto.nameForReport = "\(cashPref ?? "") \(photo.nameForReport ?? "")"
            return newPhoto
        })
        let arrayCashPhotoKE = arrayCashPhoto.filter({$0.object?.contains("KE") ?? false })
        let arrayCashPhotoWithoutKE = Array(Set(arrayCashPhoto).subtracting(arrayCashPhotoKE))
        saveImageFromPhotoArray(array: arrayCashPhotoWithoutKE, url: shopFolder)
        saveImageFromPhotoArray(array: arrayCashPhotoKE, url: shopFolderKE)
        
        var ArrayPhotoMp = photoArray.filter ({ ($0.kit == "mp") })
        ArrayPhotoMp = ArrayPhotoMp.map({ photo in
            let newPhoto = photo
            let cashPref = photo.object?.prefix(4)
            newPhoto.nameForReport = "\(cashPref ?? "") \(photo.nameForReport ?? "")"
            return newPhoto
        })
        let photoMpKE = ArrayPhotoMp.filter { $0.object?.contains("KE") ?? false }
        let ArrayPhotoMpWithoutKE = Array(Set(ArrayPhotoMp).subtracting(photoMpKE))
        saveImageFromPhotoArray(array: photoMpKE, url: shopFolderKE)
        saveImageFromPhotoArray(array: ArrayPhotoMpWithoutKE, url: shopFolder)
        
        var ArrayPhotoTd = photoArray.filter ({ ($0.kit == "td") })
        ArrayPhotoTd = ArrayPhotoTd.map({ photo in
            let newPhoto = photo
            let cashPref = photo.object?.prefix(4)
            newPhoto.nameForReport = "\(cashPref ?? "") \(photo.nameForReport ?? "")"
            return newPhoto
        })
        let ArrayPhotoTdKE = ArrayPhotoTd.filter { $0.object?.contains("KE") ?? false }
        let ArrayPhotoTdWithoutKE = Array(Set(ArrayPhotoTd).subtracting(ArrayPhotoTdKE))
        saveImageFromPhotoArray(array: ArrayPhotoTdKE, url: shopFolderKE)
        saveImageFromPhotoArray(array: ArrayPhotoTdWithoutKE, url: shopFolder)
        
        var ArrayPhotoTsd = photoArray.filter ({ ($0.kit == "tsd") })
        ArrayPhotoTsd = ArrayPhotoTsd.map({ photo in
            let newPhoto = photo
            let cashPref = photo.object?.prefix(5)
            newPhoto.nameForReport = "\(cashPref ?? "") \(photo.nameForReport ?? "")"
            return newPhoto
        })
        let ArrayphotoTsdKE = ArrayPhotoTsd.filter { $0.object?.contains("KE") ?? false }
        let photoTsdWithoutKE = Array(Set(ArrayPhotoTsd).subtracting(ArrayphotoTsdKE))
        saveImageFromPhotoArray(array: ArrayphotoTsdKE, url: shopFolderKE)
        saveImageFromPhotoArray(array: photoTsdWithoutKE, url: shopFolder)
        
        var ArrayPhotoOther = photoArray.filter ({ ($0.kit == "other") })
        ArrayPhotoOther = ArrayPhotoOther.map({ photo in
            let newPhoto = photo
            newPhoto.nameForReport = "\(photo.nameForReport ?? "")"
            return newPhoto
        })
        let ArrayPhotoOtherKE = ArrayPhotoOther.filter { $0.object?.contains("KE") ?? false }
        let ArrayphotoOtherWithoutKE = Array(Set(ArrayPhotoOther).subtracting(ArrayPhotoOtherKE))
        saveImageFromPhotoArray(array: ArrayPhotoOtherKE, url: shopFolderKE)
        saveImageFromPhotoArray(array: ArrayphotoOtherWithoutKE, url: shopFolder)
        
        DispatchQueue.main.sync {
            activityIndicator.stopAnimating()
        }
        
        countImagesCreated = 0
    }
    
    
    //MARK: - CREATE FILE
    
    
    private func saveImageFromPhotoArray(array: [Photo], url: URL){
        
        let fileManager = FileManager.default
        
        for photoInArray in array {
            let imagesFromPhoto = self.dataStoreManager.fetchImagesFromPhoto(photo: photoInArray)
            var imageCount = 0

            for imageInPhoto in imagesFromPhoto{
                
                if imagesFromPhoto.count > 1 {
                    imageCount += 1
                    guard let imageData = imageInPhoto.image else { return }
                    let imageDataForFile = UIImage(data: imageData)
               
                    let fileURL = url.appendingPathComponent("\(photoInArray.nameForReport!)_\(imageCount).jpg")
                    
                    fileManager.createFile(atPath: fileURL.path, contents: imageDataForFile?.jpegData(compressionQuality: self.compressionLevel))
                  
                    
                    countImagesCreated += 1
                    
                    // Background Thread
                    DispatchQueue.main.async {
                        self.currentCountImagesLabel.text = String(self.countImagesCreated)
                                            }
                }else{
                    guard let imageData = imageInPhoto.image else { return }
                    let imageDataForFile = UIImage(data: imageData)
               
                    let fileURL = url.appendingPathComponent("\(photoInArray.nameForReport!).jpg")
                    
                    fileManager.createFile(atPath: fileURL.path, contents: imageDataForFile?.jpegData(compressionQuality: self.compressionLevel))
                    //smallImage = UIImage()
                    countImagesCreated += 1
                    
                    DispatchQueue.main.async {
                        self.currentCountImagesLabel.text = String(self.countImagesCreated)
                  
                    }
                }
            }
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension TableOfPhotoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPhoto.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell {
            
            filteredPhoto = filteredPhoto.sorted{$0.object! < $1.object!}
            
            let photo = filteredPhoto[indexPath.row]
            
            var image:Data!
            
            if let img = dataStoreManager.fetchImagesFromPhoto(photo: photo).first?.image {
                image = img
            }else{
                image = Data()
            }
            
            guard let photoName = photo.object else {return UITableViewCell()}
            
            cell.setupCell(imageData: image, text: photoName)
            
            return cell}else{
                return UITableViewCell()
            }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.photo = self.filteredPhoto[indexPath.row]
        
        performSegue(withIdentifier: "toPhotoDescriptionVC", sender: nil)
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



