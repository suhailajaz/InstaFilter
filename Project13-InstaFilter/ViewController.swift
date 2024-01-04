//
//  ViewController.swift
//  Project13-InstaFilter
//
//  Created by suhail on 13/08/23.
//

import CoreImage
import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet var sliderIntensity: UISlider!
    @IBOutlet var imgIntensity: UIImageView!
    @IBOutlet var btnChangeFilter: UIButton!
    @IBOutlet var sliderRadius: UISlider!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    var availibleFilters: [String] = ["CIBumpDistortion","CIGaussianBlur","CIPixellate","CISepiaTone","CITwirlDistortion","CIUnsharpMask","CIVignette"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "InstaFilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        
        currentImage = UIImage(named: "IMG_2213.JPG")
        imgIntensity.image = currentImage
        
        context = CIContext()
        currentFilter = CIFilter(name: "CIVignette")
    
        //CI Image Code
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
       applyProcessing()
        
    }
    
    @objc func  importPicture(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker,animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        //CI Image Code
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @IBAction func changeFilterTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Choose Filter", message: "Select a filter from the list", preferredStyle: .actionSheet)
        for i in availibleFilters {
            ac.addAction(UIAlertAction(title: i, style: .default,handler: setFilter))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        //Makes sure that the ac pops up from a popOverPresentationController when change Filter nutton is tapped
        if let popOverController = ac.popoverPresentationController {
            popOverController.sourceView = sender
            popOverController.sourceRect = sender.bounds
        }
        
        present(ac,animated: true)
    }
    
    func setFilter(action: UIAlertAction){
        guard currentImage != nil else { return }
        
        guard let filter = action.title else { return }
        btnChangeFilter.titleLabel?.text = filter
        currentFilter = CIFilter(name: filter)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let image = imgIntensity.image else {
            let ac = UIAlertController(title: "There is no image to save!", message: "You need to select an image first from the photo library!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac,animated: true)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error : Error?, contextInfo: UnsafeRawPointer){
        if let error = error{
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac,animated: true)
        }else{
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac,animated: true)
        }
    }
    
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(sliderIntensity.value * 200, forKey: kCIInputRadiusKey)
            
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
            let processedImage = UIImage(cgImage: cgImage)
            imgIntensity.image = processedImage
        }
    }
    func applyProcessing(){
        //code to check what keys are supported by the currentFilter and handling every single one of them
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(sliderIntensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(sliderIntensity.value * 10, forKey: kCIInputScaleKey)
            
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
            
        }
        
        
        // currentFilter.setValue(sliderIntensity.value, forKey: kCIInputIntensityKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
            let processedImage = UIImage(cgImage: cgImage)
        
            imgIntensity.image = processedImage
            
            UIView.animate(withDuration: 3.5) {
                  self.imgIntensity.alpha = 0
                  self.imgIntensity.alpha = 1.0
                  
              }
        }
        
    }
}

