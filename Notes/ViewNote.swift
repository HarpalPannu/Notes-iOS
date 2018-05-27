//  ViewNote.swift
//  Notes
//  Created by Mac on 3/29/18.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit

class ViewNote: UIViewController ,  UICollectionViewDataSource , UICollectionViewDelegate {

    @IBOutlet var collHeight: NSLayoutConstraint!
    @IBOutlet var collView: UICollectionView!
    @IBOutlet var noteTitle: UITextField!
    let documentsDirPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @IBOutlet var noteText: UITextView!
    var NotesData:NoteDB?
    var Files:[String] = []
    override func viewDidLoad() {
       super.viewDidLoad()
        noteTitle.text = NotesData?.title
        noteText.text = NotesData?.note
        noteTitle.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
        noteText.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
        noteText.layer.borderWidth = 0.8;
        noteText.layer.cornerRadius = 5.0
        let button1 = UIBarButtonItem(image: UIImage(named: "map"), style: .plain, target: self, action: #selector(viewOnmap)) // action:#selector(Class.MethodName) for swift 3
        let noteTextY = noteTitle.frame.origin.y + noteTitle.frame.height + 32
        print(noteTextY)
        self.navigationItem.rightBarButtonItem  = button1
        if (!(NotesData?.files.isEmpty)!){
            Files = (NotesData?.files.components(separatedBy: ","))!
        }else{
            collHeight.constant = 0
            collView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Files.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "viewCell", for: indexPath) as! ViewCell
            let imagePath = documentsDirPath.appendingPathComponent(Files[indexPath.row])
            let fileExtension = NSURL(fileURLWithPath: imagePath.path).pathExtension
            if(fileExtension! == "caf"){
                cell.imageView.image = UIImage(named : "audio")
            }else{
                do {
                    let image = try Data(contentsOf: imagePath)
                    cell.imageView.layer.borderWidth = 0.8
                    cell.imageView.layer.borderColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0).cgColor;
                    cell.imageView.image =  UIImage(data: image)
                } catch {
                    cell.imageView.image = UIImage(named : "imgError")
                }
            }
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imagePath = documentsDirPath.appendingPathComponent(Files[indexPath.row])
        let fileExtension = NSURL(fileURLWithPath: imagePath.path).pathExtension
        if(fileExtension! == "caf"){
            performSegue(withIdentifier: "audioPlayer", sender: imagePath)
        }else{
            performSegue(withIdentifier: "imageShow", sender: imagePath)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapView" {
            let destVC = segue.destination as! MapViewController
            destVC.loactionData = sender as? String
            destVC.noteTitle = self.NotesData?.title
        }
        if segue.identifier == "imageShow" {
            let destVC = segue.destination as! ImageController
            destVC.ImagePath = sender as? URL
        }
        if segue.identifier == "audioPlayer" {
            let destVC = segue.destination as! AudioPlayer
            destVC.AudioPath = sender as? URL
        }
    }
    
    @objc func viewOnmap()  {
        let segueData = self.NotesData?.location
        performSegue(withIdentifier: "mapView", sender: segueData)
    }
}
