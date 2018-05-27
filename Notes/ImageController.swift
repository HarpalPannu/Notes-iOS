//  ImageController.swift
//  Notes
//  Created by Mac on 3/29/18.
//  Copyright © 2018 Harpal. All rights reserved.

import UIKit

class ImageController: UIViewController {

    @IBOutlet var imageV: UIImageView!
    var ImagePath:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageV.isUserInteractionEnabled = true
        let pinch = UIPinchGestureRecognizer(target:self,action:#selector(self.pinch))
        imageV.addGestureRecognizer(pinch)
        let button1 = UIBarButtonItem(image: UIImage(named: "gallery"), style: .plain, target: self, action: #selector(viewOnmap))
       
         self.navigationItem.rightBarButtonItem  = button1
        do {
            let image = try Data(contentsOf: ImagePath!)
            imageV.image =  UIImage(data: image)
        } catch {
            imageV.image = UIImage(named : "imgError")
        }
    }
    @objc func pinch(sender:UIPinchGestureRecognizer){
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
    }
    @objc func viewOnmap()  {
        UIImageWriteToSavedPhotosAlbum(imageV.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            // we got back an error!
            let ac = UIAlertController(title: "Error", message: "Unable Save", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .destructive))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
