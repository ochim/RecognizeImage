//
//  ViewController.swift
//  RecognizeImage
//
//  Created by nijibox on 2017/10/05.
//  Copyright © 2017年 recruit. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var useModel1Button: UIButton!
    @IBOutlet weak var useModel2Button: UIButton!
    
    var buttonTag:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside )

        useModel1Button.addTarget(self, action: #selector(tapSelectBtn(sender:)), for: .touchUpInside )
        useModel1Button.tag = 10

        useModel2Button.addTarget(self, action: #selector(tapSelectBtn(sender:)), for: .touchUpInside)
        useModel2Button.tag = 20

        outputLabel.numberOfLines = 0
    }
    
    @objc func selectImage() {
        let c = UIImagePickerController()
        c.delegate = self
        present(c, animated: true)
    }
    
    @objc func tapSelectBtn(sender:UIButton) {
        buttonTag = sender.tag
        var model = MobileNet().model
        if buttonTag == 20 {
            model = GoogLeNetPlaces().model
        }
        
        if let model = try? VNCoreMLModel(for: model), let image = selectedImageView.image
        {
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    return
                }
                let resultStrs = results.map { "\($0.identifier): \(NSString(format: "%.2f", $0.confidence))" }.prefix(5)
                self.outputLabel.text = "● 解析結果\n" + resultStrs.joined(separator: "\n")
            }
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cgImage: image.cgImage!)
            try! handler.perform([request])
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            selectedImageView.image = image
            outputLabel.text = ""
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

