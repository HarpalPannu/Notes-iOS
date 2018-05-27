//  AddNotes.swift
//  Notes
//  Created by Mac on 3/26/18.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit
import CoreLocation
import SQLite3
class AddNotes: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate , CLLocationManagerDelegate{
    var selectedTagCellIndex:IndexPath? = nil
    @IBOutlet weak var tagCollectionView: UICollectionView!
    var db: OpaquePointer?
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noteTitle: UITextField!
    @IBOutlet var noteText: UITextView!
    let locationManager = CLLocationManager()
    var Images:[String] = []
    var locationData:String = String()
    var TagData:[TagDB] = []
    let documentsDirPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    override func viewDidLoad() {
        super.viewDidLoad()
        if sqlite3_open(documentsDirPath.appendingPathComponent("NotesDB.db").path, &db) != SQLITE_OK {
            print("error opening database")
        }
        self.hideKeyboardWhenTappedAround()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        tagCollectionView.allowsSelection = true
        tagCollectionView.allowsMultipleSelection = false
        
        
        let tagQuery = "Select * FROM TAG"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, tagQuery, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let tag = String(cString: sqlite3_column_text(stmt, 1))
            TagData.append(TagDB(id: Int(id),tag:tag))
        }
        
        
        noteTitle.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
        noteText.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
        noteText.layer.borderWidth = 0.8;
        noteText.layer.cornerRadius = 5.0
        collectionView.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
        collectionView.layer.cornerRadius = 5.0
        collectionView.layer.borderWidth = 0.8;
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
        else{
            displayAlert(title: "Gps Error" , message: "Enable Gps To Save Note", close: true)
        }
        print(documentsDirPath)
      
    }
    override func viewDidAppear(_ animated: Bool) {
        collectionView.flashScrollIndicators()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationData = "\(locations[0].coordinate.latitude),\(locations[0].coordinate.longitude)"
    }
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            noteText.contentInset = UIEdgeInsets.zero
        } else {
            noteText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        noteText.scrollIndicatorInsets = noteText.contentInset
        
        let selectedRange = noteText.selectedRange
        noteText.scrollRangeToVisible(selectedRange)
    }
    @IBAction func cancelNotes(_ sender: Any) {
        if(Images.count > 0){
            for Image in Images{
                do{
                    let imagePath = documentsDirPath.appendingPathComponent(Image)
                    try FileManager.default.removeItem(at: imagePath)
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        self.dismiss(animated: true, completion:nil)
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            return Images.count + 1
        }else{
            return TagData.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView{
            var button:UIButton = UIButton()
            if(indexPath.row < Images.count){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notesCell", for: indexPath) as! NotesCellView
                let imagePath = documentsDirPath.appendingPathComponent(Images[indexPath.row])
                let fileExtension = NSURL(fileURLWithPath: imagePath.path).pathExtension
                if(fileExtension! == "caf"){
                    cell.imageView.image = UIImage(named : "audio")
                }else{
                    do {
                        let image = try Data(contentsOf: imagePath)
                        cell.imageView.image =  UIImage(data: image)
                    } catch {
                        cell.imageView.image = UIImage(named : "imgError")
                    }
                }
                button = UIButton(frame: CGRect(x: cell.bounds.width - 22, y: 2, width: 20, height: 20))
                button.setImage(UIImage(named : "remove"), for: .normal)
                button.addTarget(self,action: #selector(deleteImage(_:)),for: .touchUpInside)
                button.isHidden = false
                cell.addSubview(button)
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! AddNewItem
                cell.imageView.image = UIImage(named : "add.jpg")
                return cell
            }
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
            cell.label.text = TagData[indexPath.row].tag
            cell.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
            cell.layer.borderWidth = 0.8;
            cell.layer.cornerRadius = 5.0
            return cell
        }
    }
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView{
            if(indexPath.row == Images.count ){
                let alertController = UIAlertController(title: nil, message: "Add Media", preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alertController.addAction(cancelAction)
                let photoGallery = UIAlertAction(title: "Image From Photo Gallery", style: .default) {
                    action in
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.sourceType = .photoLibrary
                    imagePickerController.delegate = self
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                let camera = UIAlertAction(title: "Image From Camera", style: .default) {
                    action in
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.sourceType = .camera
                    imagePickerController.allowsEditing = true
                    imagePickerController.delegate = self
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                let recordAudio = UIAlertAction(title: "Record Audio", style: .default) {
                    action in
                    self.performSegue(withIdentifier: "recorderView", sender: nil)
                }
                alertController.addAction(recordAudio)
                alertController.addAction(camera)
                alertController.addAction(photoGallery)
                self.present(alertController, animated: true)
            }else{
                let imagePath = documentsDirPath.appendingPathComponent(Images[indexPath.row])
                let fileExtension = NSURL(fileURLWithPath: imagePath.path).pathExtension
                if(fileExtension! == "caf"){
                    performSegue(withIdentifier: "audioPlayer", sender: imagePath)
                }else{
                    performSegue(withIdentifier: "imageShow", sender: imagePath)
                }
            }
        }else{
          selectedTagCellIndex = indexPath
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageShow" {
            let destVC = segue.destination as! ImageController
            destVC.ImagePath = sender as? URL
        }
        if segue.identifier == "audioPlayer" {
            let destVC = segue.destination as! AudioPlayer
            destVC.AudioPath = sender as? URL
        }
        if segue.identifier == "recorderView" {
            let destVC = segue.destination as! RecoderView
            destVC.onSave = {
                (data) in
                self.Images.append(data)
                print(self.Images)
                self.collectionView.reloadData()
            }
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            do {
                let imageName =  String(Int64(Date().timeIntervalSince1970 * 1000)) + ".jpg"
                let imagePath = documentsDirPath.appendingPathComponent(imageName)
                if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                    try imageData.write(to: imagePath)
                    Images.append(imageName)
                    collectionView.reloadData()
                }
            }catch {
                print(error)
            }
        }
       
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteImage(_ sender:UIButton)
    {
        do {
            let buttonPosition:CGPoint = sender.convert(.zero, to: self.collectionView)
            let indexPath:IndexPath = self.collectionView.indexPathForItem(at: buttonPosition)!
            let imagePath = documentsDirPath.appendingPathComponent(Images[indexPath.row])
            try FileManager.default.removeItem(at: imagePath)
            Images.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        }
        catch{
            print("An error took place: \(error)")
        }
    }
    
    func updateDataArray(){
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirPath, includingPropertiesForKeys: nil, options: [])
            Images = directoryContents.filter{ $0.pathExtension == "jpg" }.map{ $0.deletingPathExtension().lastPathComponent + ".jpg" }
        } catch {
            print(error.localizedDescription)
        }
        print(Images)
        print(documentsDirPath)
    }
    func displayAlert(title:String,message:String,close:Bool){    //Display Alert Method
        
        let alertController = UIAlertController(title: title,message:message, preferredStyle: UIAlertControllerStyle.alert)
        if(close){
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler:{
            (action) -> Void in self.dismiss(animated: true, completion:nil)
            }))
        }else{
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayAlert(title : "Gps Error" , message: error.localizedDescription, close: false)
    }
    @IBAction func saveBtn(_ sender: Any) {
        let title = noteTitle.text! as NSString
        let text = noteText.text! as NSString
        let timeStamp = String(Date().timeIntervalSince1970) as NSString
        let files = Images.joined(separator: ",") as NSString
        let cordinates = locationData as NSString
        if(String(title).isEmpty){
            displayAlert(title : "Incomplete Data" , message: "Note Title Is Required", close: false)
            return
        }else if(noteText.text.count == 0){
            displayAlert(title : "Incomplete Data" , message: "Write Something", close: false)
            return
        }else if(locationData.isEmpty){
            displayAlert(title: "Enable Loccation ?", message: "Unable To Get Location Data", close: false)
            return
        }else if(selectedTagCellIndex == nil){
            displayAlert(title: "Incomplete Data" , message: "Select a Note Tag", close: false)
            return
        }
        var stmt: OpaquePointer?
        let queryString = "INSERT INTO Notes (TITLE,NOTE,FILES,TIMESTAMP,Location,TAGID) VALUES (?,?,?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        let tagID = String(TagData[(selectedTagCellIndex?.row)!].id) as NSString
        if sqlite3_bind_text(stmt, 1, title.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 2, text.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 3, files.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 4, timeStamp.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 5, cordinates.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 6,tagID.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }else{
            print("Done")
        }
        UserDefaults.standard.set(true, forKey: "tableUpdate")
        self.dismiss(animated: true, completion: {
            
        })
    }
}










