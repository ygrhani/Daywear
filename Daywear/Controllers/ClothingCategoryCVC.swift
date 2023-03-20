//
//  ClothingCategoryCVC.swift
//  Daywear
//
//  Created by Ann Prudnikova on 12.03.23.
//

import UIKit
import PhotosUI
import Firebase
import FirebaseStorage

private let reuseIdentifier = "Cell"

final class ClothingCategoryCVC: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    
    var currentClothingCategory: ClothingList?
    var user: User!
    private var item = [CategoryList]()
    private var ref: StorageReference!
    private var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentClothingCategory?.title
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        // Do any additional setup after loading the view.
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        // наблюдатель за значениями
    //        ref.observe(.valueType) { [weak self] snapshot in
    //            var items = [CategoryList]()
    //            for item in snapshot.children { // вытаскиваем все tasks
    //                guard let snapshot = item as? DataSnapshot,
    //                      let category = CategoryList(snapshot: snapshot) else { continue }
    //                items.append(category)
    //            }
    //            self?.item = items
    //            self?.collectionView.reloadData()
    //        }
    //    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        // удаляем всех Observers
    //        ref.removeAllObservers()
    //    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return item.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ClothingCategoryCVCell {
            let items = item[indexPath.row]
            
            fetchImage(imageURLStr: items.itemsCategory, imageView: cell.picOfClothes)

            return cell
        }
        
        // Configure the cell
        
        return UICollectionViewCell()
    }
    
    
    @IBAction func addNewPhoto(_ sender: Any) {
        
        let alertController = UIAlertController(title: "New photo", message: "Add new photo", preferredStyle: .alert)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let takePhoto = UIAlertAction(title: "take a photo", style: .default) { [self] _ in // почему с weak ошибка?
            
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion: nil)
            
        }
        
        let choosePhoto = UIAlertAction(title: "choose a photo", style: .default) { [self] _ in
            
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 10
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        present(alertController, animated: true)
        
        
    }
    
    func upload(currentUser: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let image = UIImage()
        
        guard let imageData = image.jpegData(compressionQuality: 0.0) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metaData) { metaData, error in
            guard let _ = metaData else {
                completion(.failure(error!))
                return
            }
            
            self.ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let uid = self.user.uid
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        upload(currentUser: uid, photo: image) { (result) in
            switch result {
            case .success(let url):
                
                let item = CategoryList(itemsCategory: url.absoluteString, userId: uid)
            case .failure(_): break
            }
        }
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.sync {
                        self.upload(currentUser: self.user.uid, photo: image) { (result) in
                            switch result {
                            case .success(let url):
                                
                                let item = CategoryList(itemsCategory: url.absoluteString, userId: self.user.uid)
                            case .failure(_): break
                            }
                            self.collectionView.reloadData()
                            
                        }
                    }
                    
                } else {
                    
                }
            }
        }
    }
    
    
    private func fetchImage(imageURLStr: String, imageView: UIImageView) {
        guard let url = URL(string: imageURLStr ) else {return}
        
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, reply, error in
            DispatchQueue.main.async {
                
                if let error {
                    let errorAlert = UIAlertController(title: "Something's wrong", message: error.localizedDescription, preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "OK", style: .cancel)
                    self.present(errorAlert, animated: true)
                    errorAlert.addAction(okBtn)
                    return
                }
                
                if let reply {
                    print(reply)
                }
                
                print("\n", data ?? "", "\n")
                
                if let data,
                   let image = UIImage(data: data)
                {
                imageView.image = image
                    
                } else {
                imageView.image = UIImage(systemName: "photo.artframe")
                }
                
            }
        }//.resume()
        task.resume()
    }

    
    
func upload(curntUser: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
    
    ref = Storage.storage().reference().child("itemsOfCategory").child(String(user.uid))
    
    let image = UIImage()
    
    guard let imageData = image.jpegData(compressionQuality: 0.0) else {return}
    
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpeg"
    
    ref.putData(imageData, metadata: metaData) { metaData, error in
        guard let _ = metaData else {
            completion(.failure(error!))
            return
        }
        
        self.ref.downloadURL { (url, error) in
            guard let url = url else {
                completion(.failure(error!))
                return
            }
            completion(.success(url))
        }
    }
}
    

        
        
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
