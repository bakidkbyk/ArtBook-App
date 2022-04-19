//
//  ViewController.swift
//  ArtBook-App
//
//  Created by Baki Dikbıyık on 6.04.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedId: UUID?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked)) // Navigation bar button ekleme
        
        getData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func getData(){
        
        nameArray.removeAll(keepingCapacity: false) // uygulamada aynı şeyler iki kere gözükmesin diye kullanıldı
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name =  result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    self.tableView.reloadData() //  Veri ekledikten sonra table Viewi güncellemek için
                }
                
                
            }
            
            
            
        }catch {
            
            print("error")
            
        }
    }
    
    
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVc"{
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.choosenPainting = selectedPainting
            destinationVC.choosenId = selectedId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }
    // Silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                             do {
                                try
                                    context.save()
                             }catch {
                                 print("error")
                             }
                                break

                            }
                            
                        }
                        
                    }
                }
            }catch {
                print("error")
            }
    
            
            
        }
    }
    
    
}

