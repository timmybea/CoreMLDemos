//
//  ViewController.swift
//  NotHotDog
//
//  Created by Tim Beals on 2018-11-12.
//  Copyright © 2018 Roobi Creative. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.green
        return iv
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.sourceType = .camera
        ip.allowsEditing = false
        ip.delegate = self
        return ip
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        setupNavBar()
    }
    
    override func viewWillLayoutSubviews() {
        imageView.removeFromSuperview()
        
        
        view.addSubview(imageView)
        let margins = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: margins.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
            ])
        
        
    }


}

extension ViewController {
    
    func setupNavBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonTapped(sender:)))
        
    }
    
    @objc func cameraButtonTapped(sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let userPickedImage = info[.originalImage] as? UIImage else { return }
        self.imageView.image = userPickedImage
    
        guard let ciImage = CIImage(image: userPickedImage) else {
            fatalError("Could not convert UIIMage to CIImage")
        }
        
        detect(image: ciImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        //VNCoreMLModel comes from the Vision framework
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            print(results)
        }

        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
}
