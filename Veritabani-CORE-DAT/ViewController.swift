//
//  ViewController.swift
//  Veritabani-CORE-DAT
//
//  Created by MAKAN on 7.10.2020.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self

        
        //NAVIGASYON EKLEME ISLEMI
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
   @objc func getData(){
    
        nameArray.removeAll(keepingCapacity: true) //ikinci calistirmada tekrar ayni seyleri eklemeyecek. 
        idArray.removeAll(keepingCapacity: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
//        VERILERI CEKME ISLEMI.Sonuclarini alacagimiz bir istek yapiyoruz suanda <NSFetchRequestResult> bununle.(context.fetch islemi)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false //veri data hizli gelmesi icin yaptik
        
        do {
           let results =  try context.fetch(fetchRequest)
            if results.count > 0 { // Garanti olsun diye bu islemi yaptik.
                
            for result in results as! [NSManagedObject] { //NSManagedObject core data model objesi. Tek bir result a odaklanmak icin cast ettik.
                if let name = result.value(forKey: "name")  as? String { //Bu gerceklesirse islem yapilicak.(if-let ile yapma amacimiz bu )
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
                
//                Yeni veri ekleyince, yeni veriyi gormek icin, tableview i guncelleme islemi.
                
                self.tableView.reloadData() //Yeni bir veri geldi kendini guncelle dedik.
            }
            }
        }catch {
            print("error")
        }

    }
    
   
    @objc func addButton() {
        selectedPainting = ""
        performSegue(withIdentifier: "todetailsVC", sender: nil)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
//   MARK:- Tiklaninca ne olacagini belirtiyoruz
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "todetailsVC", sender: nil)
    }
//    MARK:- Diger VC ye Veri aktarim islemi yapariz buradada.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "todetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenPaintign = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
        
    }
//    MARK:- KULLANICI CELL DEN DELETE-VEYA BASKA ISLEMLERI BU FONK YAPIYOR.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Core datadan ilgili veriyi silicez.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if  results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                
                                context.delete(result) //core datadan veriyi sildi
                                nameArray.remove(at: indexPath.row) //dizinin icindende sil secilen veriyi
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData() //tableview i guncelledik
                                
                                do {
                                    try context.save()  //Core data ile islemi bitityoruz.
                                }catch {
                                    print("error")
                                }
                                break // islem bitince for loop dan cikmak icin  break diyecez.
                                
                            }
                        }
                        
                    }
                    
                }
            } catch {
                print("error")
            }
            
        }
    }
}

