//
//  DetailsViewController.swift
//  Veritabani-CORE-DAT
//
//  Created by MAKAN on 7.10.2020.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPaintign = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        if chosenPaintign != "" {
            
            saveButton.isHidden = true // Gorunmez yapar.
//            saveButton.isEnabled = false // butonu tiklanamaz hale getirir.
            
            
           // CoreData dan veriyi gostermek icin cagiriyoruz.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
//            FITRELEME ISLEMI
            let idString = chosenPaintingId?.uuidString  //UUID i String e cevirdik
            fetchRequest.predicate = NSPredicate(format: "id = %@" , idString!) //ben bir kosul yazicam buraya o bu kosulu bulup getiricek bana buna yariyor.Yani mantiksal sinirlamalar yapiyor.
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
              let results =  try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            }catch {
                print("error")
            }
            
        }else {
            saveButton.isHidden = false
            
            
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            
        }
        
        
        
        
//        RECOGNIZERS
//        BOSLUGA/EKRANDA VC ICINDE BIR YERE TIKLAYINCA KLAVYEYI KAPATMA ISLEMI.
//        GESTURE RECIGNIZER(vc icinde her hangi bir yere dokunuldugunda klavyeyi kapat.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)//Burada gesture i view a ekledik yani ekranin kendisine ekledik.Daha once resim bakka bir seyede ekleyebiliyorduk.
        
        imageView.isUserInteractionEnabled = true //kullanici gorsele tiklayabilsin mi?(true = tiklayabilsin)
        let gestureRec = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(gestureRec)
        
        
    }
    
    @objc func selectImage(){
        
//        Kullaniciyi galeriye(kutuphaneye) goturme islemi
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary //Fotografa nasil erisicegimizi belirtiyoruz.
        picker.allowsEditing = true //Kullanici sectigi gorseli degistirebilecegi sey ile karsilasir.(zoom, kucultme vs,)
        present(picker, animated: true, completion: nil)
        
    }
    
//        RESMI SECTIKDEN SONRA NE YAPACAGINI BELIRTIYORUZ.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Media ile isimiz bitince, gorseli sectikden sonra, bu fonk bize bir tane dictionary dondurur.([UIImagePickerController.InfoKey : Any]) : Any secilen gorseldir.
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true //tiklanabilir olsun buton dedik.
        self.dismiss(animated: true, completion: nil)//Actigimiz picker i kapattik.Gorunum denetleyicisini kapatir.
        
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) //endEditing  o view icindeki degisiklikleri bitiriyor diyebiliriz.True dedigimizde klavyeyi kapatacaktir.
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        //VERI KAYDETME ISLEMI
        //Appdelegate daki context e ulasmak icin appdelegate i bir degisken olarak tanimlamamiz gerekiyor.
        //AppDelegate degisken olarak tanimlama islemi.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext  //Bu context i kullanarak bize verilen supporting fonk kullanabiliriz.
        
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context) //Paintings : veritabaninda olusturdugumuz entity dir.Yani Paintings entity nin icine veriyi kaydedicez.
        
//        Attributes
        
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        
        if let year = Int(yearText.text!) { //Eger olursa yap anlaminini iceriyor if-let burada.
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id") //swift bizim icin otomatik olarak swift UUID olusturur.
        
        //Gorseli data olarak kaydederiz.
        let data = imageView.image!.jpegData(compressionQuality: 0.5) //Gorseli alicak ve bir data ya ceviricek.
        newPainting.setValue(data, forKey: "image")
      
        do {
            try context.save()//Coredata ya veri kaydetmemize yarayan fonk budur.Bu bir throw (hata) verebilicegiz icin do-try-catch icine aliriz.
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true) //Bu sekilde bir onceki viewController a geri gidebiliyoruz isimiz bitince.
        
    }
    
}
