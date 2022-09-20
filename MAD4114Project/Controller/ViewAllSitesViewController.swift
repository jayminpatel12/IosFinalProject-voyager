//
//  ViewController.swift
//  MAD4114Project
//
//  Created by Edgar on 6/9/22.
//

import UIKit
import CoreData
import CoreLocation

class SitesViewCell: UICollectionViewCell{
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var siteLabel: UILabel!
}

class ViewAllSitesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sitesCollectionView: UICollectionView!
    var site: [Site] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return site.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let oneSite = site[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sitesViewCell", for: indexPath) as! SitesViewCell
        cell.siteImage.image = nil
        cell.siteLabel?.text =
              oneSite.value(forKeyPath: "name") as? String
        
        let mediaFiles = oneSite.media
        
        for case let media as Media in mediaFiles!  {
            if(media.type == 1){
                continue
            }
            
            let fileUrl = URL(string: media.url!)
            do{
                let imageData = try Data(contentsOf: fileUrl!)
                cell.siteImage.image = UIImage(data: imageData)
                break
            }catch{
                //error loading image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ViewSite", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewSiteController") as! ViewSiteController
        self.navigationController?.show(vc, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sites Log"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Site", style: .plain, target: self, action: #selector(addTapped))

        // Do any additional setup after loading the view.
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        self.title = "Sites Log"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

         guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
             return
         }
         
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         let fetchRequest =
           NSFetchRequest<Site>(entityName: "Site")
         
         do {
             site = try managedContext.fetch(fetchRequest)
             site.reverse()
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
        self.sitesCollectionView.reloadData()
    }
    
    @objc func addTapped(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddSite", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AddSiteViewController") as! AddSiteViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    private func setUpCollectionView() {
        sitesCollectionView.delegate = self
        sitesCollectionView.dataSource = self
    }
}

