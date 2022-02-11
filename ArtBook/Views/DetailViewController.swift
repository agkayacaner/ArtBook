//
//  DetailViewController.swift
//  ArtBook
//
//  Created by Caner Ağkaya on 10.02.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var artistLabel: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenPainting = ""
    var choosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if choosenPainting != ""{
            saveButton.isHidden = true
            // Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context =  appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = choosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@",idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            titleLabel.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistLabel.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearLabel.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("Error!")
            }
        }else{
            saveButton.isEnabled = false
            saveButton.isHidden = false
            titleLabel.text = ""
            artistLabel.text = ""
            yearLabel.text = ""
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        // Attributes
        
        newPainting.setValue(titleLabel.text, forKey: "name")
        newPainting.setValue(artistLabel.text, forKey: "artist")
        
        if let year = Int(yearLabel.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Success!")
        }catch{
            print("Error!")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newdata"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
