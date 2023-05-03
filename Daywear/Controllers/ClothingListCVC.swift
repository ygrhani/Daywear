//
//  ClothingListCVC.swift
//  Daywear
//
//  Created by Ann Prudnikova on 27.02.23.
//

import UIKit
import Firebase
import FirebaseStorage
import VegaScrollFlowLayout


final class ClothingListCVC: UICollectionViewController {
    
    private var user: User!
    private var ref: DatabaseReference!
    private var category = [ClothingList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
            user = User(user: currentUser)
            
            ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("categories")
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9905706048, green: 0.8760409168, blue: 0.6444740729, alpha: 1)
        collectionView.tintColor = #colorLiteral(red: 0.4666666667, green: 0.4039215686, blue: 0.7490196078, alpha: 0.71)
        
        let layout = VegaScrollFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: collectionView.frame.width, height: 87)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // наблюдатель за значениями
        ref.observe(.value) { [weak self] snapshot in
            var categories = [ClothingList]()
            for item in snapshot.children { // вытаскиваем все categories
                guard let snapshot = item as? DataSnapshot,
                      let category = ClothingList(snapshot: snapshot) else { continue }
                categories.append(category)
            }
            self?.category = categories
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // удаляем всех Observers
        ref.removeAllObservers()
    }


    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        category.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Categories", for: indexPath) as? ClothingListCVCell else { fatalError("Wrong cell class dequeued")
        }
        
        let currentCategory = category[indexPath.row]
        cell.nameCategory.text =  currentCategory.title
        
        cell.makeCell()
//        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
//        let blurEffect = UIVisualEffectView(effect: blur)
//        blurEffect.bounds = cell.bounds
//        blurEffect.frame.origin.x = cell.layer.frame.origin.x
//        blurEffect.layer.frame.origin.x = cell.layer.frame.origin.x
//        cell.insertSubview(blurEffect, at: 0)
        // Configure the cell
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categoryItem = storyboard?.instantiateViewController(withIdentifier: "itemList") as? ClothingCategoryVC else {return}
        let categoryList = category[indexPath.row]
        categoryItem.currentClothingCategory = categoryList
        categoryItem.user = user
        navigationController?.pushViewController(categoryItem, animated: true)
        
        // if !isEditing {}

    }


    @IBAction func addNewCategory(_ sender: Any) {
        
        let alertController = UIAlertController(title: "New category", message: "Add new category", preferredStyle: .alert)
        alertController.addTextField()
        
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            // достали text
            guard let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let uid = self?.user.uid
            else {
                return
            }
            // создаем задачу
            let category = ClothingList(title: text, userId: uid)
            // где хранится на сервере
            let catRef = self?.ref.child(category.title.lowercased()) // нижний регистр
            // добавляем на сервак
            catRef!.setValue(category.convertToDictionary()) // помещаем словарь по ref
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    @IBAction func singOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func goToOutfits(_ sender: Any) {
        
        guard let outfitsListCVC = storyboard?.instantiateViewController(withIdentifier: "OutfitsList") as? OutfitsListCVC else {return}
        
        navigationController?.pushViewController(outfitsListCVC, animated: true)
        
    }
    
    
//    override func collectionView(_ collectionView: UICollectionView, canEditRowAt indexPath: IndexPath) -> Bool {
//        true
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, commit editingStyle: UICollectionViewCell., forRowAt indexPath: IndexPath) {
//        if editingStyle != .e { return }
//        let task = tasks[indexPath.row]
//        // удаление
//        task.ref?.removeValue()
//    }
    
    // MARK: UICollectionViewDelegate


}
