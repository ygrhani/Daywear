//
//  ClothingCategoryVC.swift
//  Daywear
//
//  Created by Ann Prudnikova on 24.04.23.
//

import UIKit
import PhotosUI
import Firebase
import FirebaseStorage

class ClothingCategoryVC: UIViewController, UINavigationBarDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentClothingCategory: ClothingList?
    var user: User!
    var itemsOfCategory = [CategoryList]()
    private var refData: DatabaseReference!
    private var refStorage: StorageReference!
    private var imagePicker: UIImagePickerController!
    @IBOutlet weak var loadBttn: UIBarButtonItem!
    @IBOutlet weak var deleteBttn: UIBarButtonItem!
    @IBOutlet weak var addBttn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadBttn.isEnabled = false
        deleteBttn.isEnabled = false
        
        title = currentClothingCategory?.title
        navigationItem.rightBarButtonItem = editButtonItem
        
        refData = Database.database().reference(withPath: "users").child(String(user.uid)).child("categories").child(String(currentClothingCategory!.title)).child("category")
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9905706048, green: 0.8760409168, blue: 0.6444740729, alpha: 1)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // наблюдатель за значениями
        refData.observe(.value) { [weak self] snapshot in
            var items = [CategoryList]()
            for item in snapshot.children { // вытаскиваем все ссылки
                guard let snapshot = item as? DataSnapshot,
                      let category = CategoryList(snapshot: snapshot) else { continue }
                items.append(category)
            }
            self?.itemsOfCategory = items
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // удаляем всех Observers
        refData.removeAllObservers()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let uid = self.user.uid
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        upload(curntUser: uid, category: self.currentClothingCategory!.title, photo: image) { (result) in
            switch result {
            case .success(let url):
                
                let item = CategoryList(itemsCategory: url.absoluteString, itemsCategoryUUID: self.refStorage.name, userId: uid)
                let itemRef = self.refData.child("item\(self.itemsOfCategory.count)")
                itemRef.setValue(item.convertToDictionary())
                
            case .failure(_): break
            }
        }
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    
                    self.upload(curntUser: self.user.uid, category: self.currentClothingCategory!.title, photo: image) { (result) in
                        switch result {
                        case .success(let urls):
                            
                            var url = urls.absoluteString
                            
                            url.replace(".", with: ",")
                            url.replace("#", with: "§")
                            url.replace("'", with: "±")
                            
                            
                            let item = CategoryList(itemsCategory: url, itemsCategoryUUID: self.refStorage.name, userId: self.user.uid)
                            
                            let itemRef = self.refData.child("item\(self.itemsOfCategory.count)")
                            itemRef.setValue(item.convertToDictionary())
                            
                        case .failure(_): break
                        }
                    }
                }
            }
        }
    }
    
    
    func upload(curntUser: String, category: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let imageUUID = UUID()
        
        refStorage = Storage.storage().reference().child("All Items").child(curntUser)
            .child("Items Of Category").child(category).child(imageUUID.uuidString)
        
        
        guard let imageData = photo.pngData() else {return}
        
        
        refStorage.putData(imageData, metadata: nil) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.refStorage.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                
                
                completion(.success(url))
                
            }
        }
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.allowsMultipleSelection = editing
        loadBttn.isEnabled = editing
        deleteBttn.isEnabled = editing
        addBttn.isEnabled = !editing
        
        collectionView.indexPathsForSelectedItems?.forEach({ (indexPath) in
            collectionView.deselectItem(at: indexPath, animated: false)
        })
        collectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            guard let cell = collectionView.cellForItem(at: indexPath) as? ClothingCategoryCVCell else {return}
            cell.isEditing = editing
        }
    }
    
    @IBAction func deleteSelectedItems(_ sender: UIBarButtonItem) {
        collectionView.indexPathsForSelectedItems?.forEach { (indexPath) in
            let selectedItems = itemsOfCategory[indexPath.row]
            selectedItems.ref?.removeValue()
            
            refStorage = Storage.storage().reference().child("All Items").child(user.uid).child("Items Of Category").child((String(currentClothingCategory!.title))).child(selectedItems.itemsCategoryUUID)
            
            refStorage.delete { error in
                if let error = error {
                    print(error)
                } else {
                    
                }
            }
        }
    }
    
    @IBAction func loadSelectedItems(_ sender: UIBarButtonItem) {
        guard let outfitItems = storyboard?.instantiateViewController(withIdentifier: "CreateOutfits") as? CreateOutfitsVC else {return}
        
        collectionView.indexPathsForSelectedItems?.forEach { (indexPath) in
            
            let selectedItems = itemsOfCategory[indexPath.row]
            
            outfitItems.selectedItemForOutfit.selectedItems?.append((String(selectedItems.itemsCategory!)))
            
            //            outfitItems.selectedItemsForOutfit.selectedItems.append(cell.picOfClothes.image)
            //            outfitItems.imViewForItems.image = cell.picOfClothes.image
            //            outfitItems.imageViewArray.append(outfitItems.imViewForItems)
            
            //
            //            guard let image = cell.picOfClothes.image else {return}
            //            let imageView = UIImageView(image: image)
            //
            //            outfitItems.imViewForItems = imageView
            
        }
        navigationController?.pushViewController(outfitItems, animated: true)
    }
}

extension UIViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return [CategoryList]().count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Category", for: indexPath) as? ClothingCategoryCVCell else { fatalError("Wrong cell class dequeued")
        }
        
        let items = [CategoryList]()[indexPath.row]
        cell.makeCell()
        cell.isEditing = isEditing
        
        
        fetchImage(imageURLStr: items.itemsCategory!, image: cell.picOfClothes)

        return cell
    }
    
   private func fetchImage(imageURLStr: String, image: UIImageView) {
         
         var newURL: String = imageURLStr
         
         newURL.replace(",", with: ".")
         newURL.replace("§", with: "#")
         newURL.replace("±", with: "'")
         
         let url = URL(string: newURL)!
         let urlRequest = URLRequest(url: url)
         let task = URLSession.shared.dataTask(with: urlRequest) { data, reply, error in
             DispatchQueue.main.async {
                 
                 if let error {
                     image.image = UIImage(systemName: "clear")
                     let errorAlert = UIAlertController(title: "Something's wrong", message: error.localizedDescription, preferredStyle: .alert)
                     let okBtn = UIAlertAction(title: "OK", style: .cancel)
                     self.present(errorAlert, animated: true)
                     errorAlert.addAction(okBtn)
                     return
                 }
                 
                 if let reply {
                     print(reply)
                 }
                 
                 image.image = UIImage(data: data!)
             }
         }
         task.resume()
     }
     
    
    
}
