//
//  DetailsViewController.swift
//  ArtBook-App
//
//  Created by Baki Dikbıyık on 6.04.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenPainting = ""
    var choosenId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenPainting != "" {
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            let idString = choosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("error")
            }
            
        }
        else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        imageView.isUserInteractionEnabled = true // kullanıcı görsele tıklamayı aktif eder
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage)) // görsel harici yere tıklanırsa görseli kapar
        imageView.addGestureRecognizer(imageRecognizer)
        
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()  // galeriye ulaşır
        picker.delegate = self // delegate aktif etme
        picker.sourceType = .photoLibrary // galeriye gönderme
        present(picker, animated: true, completion: nil) // tıklandığında galeriye götürür
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) // görseli seçtikten sonra yapılacak iş için kullanılan fonksiyon
    {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5) // seçilen resmi ayarlama
        newPainting.setValue(data, forKey: "image")
        
        do  {
            try context.save()
        }catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil) // bu sınıf diğer view controllere mesaj yollama fırsatı sağlar
        self.navigationController?.popViewController(animated: true) // save button tıklanınca bir önceki ekrana dönme
        
    }
    
    
    
    
    
}
