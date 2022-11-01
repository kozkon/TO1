//
//  ViewController.swift
//  TO
//
//  Created by Константин Козлов on 13.01.2022.
//

import UIKit

class ConfigureReportsVC: UIViewController {
    
    private var cashCount: Int = 2
    private var TDCount: Int = 2
    private var TSDCount: Int = 2
    private var MPCount: Int = 1
    private var results: Array<[String: AnyObject]> = []
    private var currentShopFormat: String = "mm"
    private var cashNumber = 1
    private var TDNumber = 1
    private var TSDNumber = 1
    private var MPNumber = 1
    
    private var dataStoreManager = DataStoreManager()
    private var shopName = ""
    
    @IBOutlet weak var TFShopName: UITextField!
    @IBOutlet weak var segmentedShopFormat: UISegmentedControl!
    @IBOutlet weak var labelCashCount: UILabel!
    @IBOutlet weak var stepperCashCount: UIStepper!
    @IBOutlet weak var labelTSDCount: UILabel!
    @IBOutlet weak var stepperTSDCount: UIStepper!
    @IBOutlet weak var labelTDCount: UILabel!
    @IBOutlet weak var stepperTDCount: UIStepper!
    @IBOutlet weak var labelMPCount: UILabel!
    @IBOutlet weak var stepperMPCount: UIStepper!
    
    @IBAction func actionChoiceShopFormat(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentShopFormat = "mm"
        case 1:
            currentShopFormat = "mk"
        case 2:
            currentShopFormat = "ma"
        default: break
        }
    }
    
    
    @IBAction func actionStepperCashCount(_ sender: UIStepper) {
        labelCashCount.text = String(Int( sender.value))
        cashCount = Int(sender.value)
    }
    
    @IBAction func actionStepprerTSDCount(_ sender: UIStepper) {
        labelTSDCount.text = String(Int( sender.value))
        TSDCount = Int(sender.value)
    }
    
    @IBAction func actionStepperTDCount(_ sender: UIStepper) {
        labelTDCount.text = String(Int( sender.value))
        TDCount = Int(sender.value)
    }
    
    @IBAction func actionStepperMPCount(_ sender: UIStepper) {
        labelMPCount.text = String(Int( sender.value))
        MPCount = Int(sender.value)
    }
    
    @IBAction func actionFurtherButton(_ sender: UIButton) {
        getDataFromFile()
        
        performSegue(withIdentifier: "toTableOfPhotoVC", sender: Any?.self)
        
        results.removeAll()
        cashNumber = 1
        TDNumber = 1
        TSDNumber = 1
        MPNumber = 1
        
    }
    
    
    private func configureStepper(stepper: UIStepper, minValue: Double, defaultValue: Double){
        stepper.value = defaultValue
        stepper.minimumValue = minValue
    }
    
    
    private func configureAllStepper(){
        configureStepper(stepper: stepperCashCount, minValue: 1, defaultValue: 2)
        configureStepper(stepper: stepperTSDCount, minValue: 1, defaultValue: 2)
        configureStepper(stepper: stepperTDCount, minValue: 1, defaultValue: 2)
        configureStepper(stepper: stepperMPCount, minValue: 1, defaultValue: 1)
    }
    
    
    private func getDataFromFile(){
        
        var filteredCashPhoto: Array<[String: AnyObject]> = []
        var filteredUKSPhoto: Array<[String: AnyObject]> = []
        var filteredOtherPhoto: Array<[String: AnyObject]> = []
        var filteredTDPhoto: Array<[String: AnyObject]> = []
        var filteredTSDPhoto: Array<[String: AnyObject]> = []
        var filteredMPPhoto: Array<[String: AnyObject]> = []
        
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOf: URL(fileURLWithPath: pathToFile)) else {return}
        
        let photoArrayConfigure = dataArray as! Array<Dictionary<String, AnyObject>>  //Получение массива словарей из data.plist
        
        var cashPhotoArray :Array<Dictionary<String, AnyObject>> = [] // массив словарей кассовых фото в зависимости от выбранного формата и количества касс
        
        var TDPhotoArray :Array<Dictionary<String, AnyObject>> = [] // массив словарей фото ТД в зависимости от выбранного  количества ТД
        
        var TSDPhotoArray :Array<Dictionary<String, AnyObject>> = [] // массив словарей фото ТСД в зависимости от выбранного количества ТСД
        
        var MPPhotoArray :Array<Dictionary<String, AnyObject>> = [] // массив словарей фото МП в зависимости от выбранного количества МП
        
        
        //Наполнение массива кассовых фото
        filteredCashPhoto = photoArrayConfigure.filter({ $0["format"]?.contains(self.currentShopFormat) ?? false }).filter({$0["kit"]?.contains("cash") ?? false })
        
        for _ in 0..<cashCount {
            
            for var item in filteredCashPhoto {
                let itemCashObjectName = item["object"] as! String
                let itemFullCashObjectName = "Касса \(cashNumber) \(itemCashObjectName)"
                
                item["object"] = itemFullCashObjectName as AnyObject
                
                cashPhotoArray.append(item)
            }
            
            self.cashNumber += 1
        }
        self.results = cashPhotoArray
        
        //Наполнение массива фото УКС
        filteredUKSPhoto = photoArrayConfigure.filter({ $0["format"]?.contains(self.currentShopFormat) ?? false }).filter({$0["kit"]?.contains("uks") ?? false })
        
        self.results += filteredUKSPhoto
        
        //Наполнение массива прочих фото
        filteredOtherPhoto = photoArrayConfigure.filter({ $0["format"]?.contains("other") ?? false }).filter({$0["kit"]?.contains("other") ?? false })
        self.results += filteredOtherPhoto
        
        //Весы напольные (только в ММ и в "прочем")
        let floorScales = photoArrayConfigure.filter({ $0["format"]?.contains(self.currentShopFormat) ?? false }).filter({$0["kit"]?.contains("other") ?? false })
        self.results += floorScales
        
        //наполнения массива фото ТД
        filteredTDPhoto = photoArrayConfigure.filter({ $0["format"]?.contains("other") ?? false }).filter({$0["kit"]?.contains("td") ?? false })
        
        for _ in 0..<TDCount {
            
            for var item in filteredTDPhoto {
                let itemTDObjectName = item["object"] as! String
                let itemFullTDObjectName = "ТД \(TDNumber) \(itemTDObjectName)"
                
                item["object"] = itemFullTDObjectName as AnyObject
                
                TDPhotoArray.append(item)
            }
            self.TDNumber += 1
        }
        self.results += TDPhotoArray
        
        //наполнения массива фото ТСД
        filteredTSDPhoto = photoArrayConfigure.filter({ $0["format"]?.contains("other") ?? false }).filter({$0["kit"]?.contains("tsd") ?? false })
        
        for _ in 0..<TSDCount {
            
            for var item in filteredTSDPhoto {
                let itemTSDObjectName = item["object"] as! String
                let itemFullTSDObjectName = "ТСД \(TSDNumber) \(itemTSDObjectName)"
                
                item["object"] = itemFullTSDObjectName as AnyObject
                
                TSDPhotoArray.append(item)
            }
            self.TSDNumber += 1
        }
        self.results += TSDPhotoArray
        
        //наполнения массива фото МП
        filteredMPPhoto = photoArrayConfigure.filter({ $0["format"]?.contains("other") ?? false }).filter({$0["kit"]?.contains("mp") ?? false })
        
        for _ in 0..<MPCount {
            
            for var item in filteredMPPhoto {
                let itemMPObjectName = item["object"] as! String
                let itemFullMPObjectName = "МП \(MPNumber) \(itemMPObjectName)"
                
                item["object"] = itemFullMPObjectName as AnyObject
                
                MPPhotoArray.append(item)
            }
            self.MPNumber += 1
        }
        self.results += MPPhotoArray
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAllStepper()
        
        self.TFShopName.delegate = self
        hideKeyboardWhenTappedAround()
        
        title = "Параметры отчета"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTableOfPhotoVC"{
            guard let fotoTable = segue.destination as? TableOfPhotoVC else {return}
            fotoTable.arrayOfDictionaryPhoto = results
            guard let shopName = TFShopName.text else {return}
            fotoTable.shopName = shopName
            
            fotoTable.cashCount = cashCount
            fotoTable.TDCount = TDCount
            fotoTable.TSDCount = TSDCount
            fotoTable.MPCount = MPCount
        }
    }
}


extension ConfigureReportsVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
