//
//  AddSiteViewController.swift
//  MAD4114Project
//
//  Created by Edgar on 7/9/22.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreLocation
import MobileCoreServices
import UniformTypeIdentifiers
import PhotosUI
import AVKit
import AVFoundation



class AddSiteViewController: UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet weak var image1: UIButton!
    @IBOutlet weak var image2: UIButton!
    @IBOutlet weak var image3: UIButton!
    @IBOutlet weak var video1: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
 
    var sitesObjectsArray: [NSManagedObject] = []
    var mediaObjectsArray: [NSManagedObject] = []
    private var mediaVC = UIImagePickerController()
    private var configuration = PHPickerConfiguration(photoLibrary: .shared())
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var siteNameTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    
    var mediaArray: [MediaManager]  = []
    var videoURL: URL!
    
    //MARK: - AddNewSite driver code
    @IBAction func addNewSite(_ sender: Any) {
        if(siteNameTextField.text == "" || latitudeTextField.text == "" || longitudeTextField.text == ""){
            return;
        }
        if(mediaArray.isEmpty){
            return;
        }
        
        let siteName = siteNameTextField.text ?? ""
        let siteLatitude = Double(latitudeTextField.text ?? "")!
        let siteLongitude = Double(longitudeTextField.text ?? "")!
        
        self.save(name: siteName, latitude: siteLatitude, longitude: siteLongitude)
    }
    
    func save(name: String, latitude:Double, longitude:Double) {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let site = Site(context: managedContext)

        site.setValue(name, forKeyPath: "name")
        site.setValue(latitude, forKeyPath: "latitude")
        site.setValue(longitude, forKeyPath: "longitude")
        
        for mediaObject in self.mediaArray{
            
            let media = Media(context: managedContext)
            
            media.url = mediaObject.url.absoluteString
            media.type = mediaObject.type
            
            mediaObjectsArray.append(media)
        }
        
        site.media = NSSet.init(array: mediaObjectsArray)
        
        do {
            sitesObjectsArray.append(site)
            
            try managedContext.save()
            let alert = UIAlertController(title: "Add Site", message: "Your Site has been added successfully", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Great!", style: UIAlertAction.Style.default, handler: { action in
                self.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
                                         ))
            self.present(alert, animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        self.title = "Add New Site"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let locManager = CLLocationManager()

        if CLLocationManager.locationServicesEnabled(){
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
            var currentLocation: CLLocation!
            currentLocation = locManager.location
            
            if(currentLocation != nil){
                longitudeTextField.text = "\(currentLocation.coordinate.longitude)"
                latitudeTextField.text = "\(currentLocation.coordinate.latitude)"
                let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapView.setRegion(mRegion, animated: true)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    var currentButton = ""

    @IBAction func captureImage(_ sender: UIButton) {
        
        self.currentButton = sender.restorationIdentifier!
        
        let alert = UIAlertController(title: "Upload media", message: "Where would you like to upload media from?", preferredStyle: .alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Use Camera", style: UIAlertAction.Style.default, handler: {
            [self]action in captureMediaUsingCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "From Gallery", style: UIAlertAction.Style.default, handler: {
            [self]action in pickMediaFromGallery()
        }))
        self.present(alert, animated: true, completion: nil)
        self.mediaVC = UIImagePickerController() //reset
    }
    
    //load image from gallery
    @objc func pickMediaFromGallery() {
        mediaVC.allowsEditing = true
        
        if(currentButton != "video1"){
            mediaVC.mediaTypes = [ UTType.image.identifier ]
        }else{
            mediaVC.mediaTypes = [ UTType.movie.identifier ]
        }
        
        mediaVC.delegate = self
        present(mediaVC, animated: true)
    }
    
    //use camera for image capture
    @objc func captureMediaUsingCamera() {
        mediaVC.sourceType = .camera
        
        if(currentButton != "video1"){
            mediaVC.mediaTypes = [ UTType.image.identifier ]
        }else{
            mediaVC.mediaTypes = [ UTType.movie.identifier ]
        }
        
        mediaVC.allowsEditing = false
        mediaVC.delegate = self
        present(mediaVC, animated: true, completion: nil)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        
        let videoURL = self.videoURL
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
}

//MARK: - extensions for UIImagePickerController - both from camera and from gallery
extension AddSiteViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // TODO: works for both gallery and raw images
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                guard let image = info[.originalImage] as? UIImage else { return }
                
                let imageName = UUID().uuidString
                
                do{
                    guard let folderURL = URL.createFolder(folderName: "StoredImages") else {
                        print("Can't create url")
                        return
                    }
                    
                    let permanentFileURL = folderURL.appendingPathComponent(imageName).appendingPathExtension("jpg")
                    
                    if let jpegData = image.jpegData(compressionQuality: 0.8) {
                        try? jpegData.write(to: permanentFileURL)
                    }
                    
                    let newMedia = MediaManager()
                    newMedia.url = permanentFileURL
                    newMedia.type = 0
                    
                    if(currentButton == "image1"){
                        self.imageView1.image = image
                        self.image1.isEnabled = false
                    }else if(currentButton == "image2"){
                        self.imageView2.image = image
                        self.image2.isEnabled = false
                    }else if(currentButton == "image3"){
                        self.imageView3.image = image
                        self.image3.isEnabled = false
                    }
                    
                    mediaArray.append(newMedia)
                }
                
                
                
            }
            
            if mediaType == "public.movie" {
                guard let movieUrl = info[.mediaURL] as? URL else { return }
                let videoURL = URL(string: movieUrl.absoluteString)!
                self.videoURL = videoURL
                let videoName = UUID().uuidString
                do{
                    guard let folderURL = URL.createFolder(folderName: "StoredVideos") else {
                        print("Can't create url")
                        return
                    }

                    let permanentFileURL = folderURL.appendingPathComponent(videoName).appendingPathExtension("MOV")
                    let videoData = try Data(contentsOf: movieUrl)
                    try videoData.write(to: permanentFileURL, options: .atomic)
                        
                        let newMedia = MediaManager()
                        newMedia.url = videoURL
                        newMedia.type = 1
                        
                        mediaArray.append(newMedia)
                    
                        self.video1.isEnabled = false
                        self.playButton.isEnabled = true
                        
                    }catch{
                        //Error when trying to save Video
                    }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
}
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
