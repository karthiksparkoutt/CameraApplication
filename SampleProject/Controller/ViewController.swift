//
//  ViewController.swift
//  SampleProject
//
//  Created by Karthik Rajan T  on 11/09/20.
//  Copyright © 2020 Karthik Rajan T . All rights reserved.
//

import UIKit
import iOSPhotoEditor

class ViewController: UIViewController {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnChooseImage: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    var imagePicker = UIImagePickerController()
    var images = [UIImage]()
    var _selectedCells = [IndexPath]()
    var allSelected = [IndexPath]()
    fileprivate func extractedFunc() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let url = URL(string: "https://homepages.cae.wisc.edu/~ece533/images/fruits.png")
        self.imgProfile.downloadImage(from: url!)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        extractedFunc()
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
         super.setEditing(editing, animated: animated)
         
         collectionView.allowsMultipleSelection = editing
         let indexPaths = collectionView.indexPathsForVisibleItems
         for indexPath in indexPaths {
             let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
             cell.isInEditingMode = editing
         }
     }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imgProfile.layer.borderWidth = 1
        self.imgProfile.layer.borderColor = UIColor.lightGray.cgColor
        self.btnChooseImage.layer.cornerRadius = 5
    }
    @IBAction func deleteItem(_ sender: Any) {
        if let selectedCells = collectionView.indexPathsForSelectedItems {
          let items = selectedCells.map { $0.item }.sorted().reversed()
          for item in items {
              images.remove(at: item)
          }
          collectionView.deleteItems(at: selectedCells)
          deleteButton.isEnabled = false
        }
    }
    @IBAction func btnChooseImageOnClick(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
       URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    //MARK: - Open the camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Choose image from camera roll
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    @objc func deleteUser(sender:UIButton) {
        let i = sender.tag
        images.remove(at: i)
        collectionView.reloadData()
    }
    func callbackForCell() -> ((UICollectionViewCell)->Void){ // option callback
        return { [weak self] cell in
            guard let `self` = self else { return }
            guard let index = self.collectionView.indexPath(for: cell) else { return }
            
            self.images.remove(at: index.item)
            self.collectionView.reloadData()
        }
    }
    
}

//MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        picker.dismiss(animated: true, completion: nil)
        
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.image = image
        photoEditor.image = image
        photoEditor.hiddenControls = [.crop, .draw, .share]
        photoEditor.colors = [.red,.blue,.green]
        present(photoEditor, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.uploadImageView.image = images[indexPath.item]
        cell.deleteButton.addTarget(self, action: #selector(deleteUser(sender:)), for: UIControl.Event.touchUpInside)
        cell.isInEditingMode = isEditing
        
        return cell
    }
    
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
                 deleteButton.isEnabled = false
             } else {
                 deleteButton.isEnabled = true
             }
//        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
//        popOverVC.getImage = images[indexPath.row]
//        self.addChild(popOverVC)
//        popOverVC.view.frame = self.view.frame
//        self.view.addSubview(popOverVC.view)
//        popOverVC.didMove(toParent: self)
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
            deleteButton.isEnabled = false
        }
    }
}
//MARK: - PhotoEditorDelegate
extension ViewController: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        imgProfile.image = image
        images.insert(image, at: 0)
        imgProfile.image = image
        collectionView.reloadData()
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}
extension UIImageView {
   func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
      URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
   }
   func downloadImage(from url: URL) {
      getData(from: url) {
         data, response, error in
         guard let data = data, error == nil else {
            return
         }
         DispatchQueue.main.async() {
            self.image = UIImage(data: data)
         }
      }
   }
}
