//
//  ViewController.swift
//  TO
//
//  Created by Константин Козлов on 13.01.2022.
//

import UIKit
import CoreData
import AVFoundation

class StartVC: UIViewController{
    
    @IBOutlet weak var createReportButton: UIButton!
    
    private let dataStoreManager = DataStoreManager()
    private var shopName: String!
    private var shops: [Shop] = []
    private var shopNameForDelete: String!
    @IBOutlet weak var tableView: UITableView!
    
    private func fetchData(){
        shops = dataStoreManager.fetchShops()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "Фотоотчет ТО"
        self.createReportButton.layer.cornerRadius = 10
        
        fetchData()
        
       // print(UIDevice.current.userInterfaceIdiom == .p)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromExistingShop"{
            guard let tableOfPhoto = segue.destination as? TableOfPhotoVC else {return}
            tableOfPhoto.shopName = shopName
        }
    }
}


//MARK: UITableViewDataSource
extension StartVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StartCell", for: indexPath)
        cell.textLabel?.text = shops[indexPath.row].name
        cell.textLabel?.textColor = .gray
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        shopName = shops[indexPath.row].name
        performSegue(withIdentifier: "fromExistingShop", sender: nil)
    }
}


//MARK: UITableViewDelegate
extension StartVC: UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "удалить") {[weak self] _, _, completionHandler in
            
            guard let self = self else {return}
            guard let shopNameForDelete = self.shops[indexPath.row].name else {return}
            
            let ac = UIAlertController(title: "Удаление фотоочета", message: "Вы удаляете фотоотчет \" \(shopNameForDelete )\"", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                
                DispatchQueue.main.async {
                    let shops = self.dataStoreManager.fetchShops()
                    guard let shopToDelete = shops.filter ({
                        
                        $0.name == self.shops[indexPath.row].name
                    }).first else {return}
                    self.shopNameForDelete = shopToDelete.name
                    self.dataStoreManager.deleteDataObject(object: shopToDelete)
                    
                    self.shops.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.fetchData()
                }
            }
            
            let cancelAction =  UIAlertAction(title: "Отмена", style: .cancel)
            ac.addAction(deleteAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}





