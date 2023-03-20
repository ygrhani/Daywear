//
//  ClothingListCVC.swift
//  Daywear
//
//  Created by Ann Prudnikova on 27.02.23.
//

import UIKit
import Firebase
import FirebaseStorage


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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        category.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            let currentCategory = category[indexPath.row]
        cell.categoryName.text = currentCategory.title
        
    // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categoryItem = storyboard?.instantiateViewController(withIdentifier: "itemList") as? ClothingCategoryCVC else {return}
        let categoryList = category[indexPath.row]
        categoryItem.currentClothingCategory = categoryList
        categoryItem.user = user
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
        // action 2
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
