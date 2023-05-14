//
//  CreateOutfitsVC.swift
//  Daywear
//
//  Created by Ann Prudnikova on 24.03.23.
//

import UIKit

class CreateOutfitsVC: UIViewController {

    var selectedItemForOutfit = CreateOutfits(selectedItems: "")
    
    var urlItemsForOutfits: [String] = []
    
    
    
    @IBOutlet weak var viewToCreate: UIView!
    @IBOutlet weak var stackViewForItm: UIStackView!
    
    
    let imageViewForItems = UIImageView()
    
    let penAction = UIPanGestureRecognizer(target:CreateOutfitsVC.self, action:#selector(dragging))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.9905706048, green: 0.8760409168, blue: 0.6444740729, alpha: 1)
        viewToCreate.layer.cornerRadius = 30
        viewToCreate.layer.borderColor = #colorLiteral(red: 0.4666666667, green: 0.4039215686, blue: 0.7490196078, alpha: 0.71)
        viewToCreate.layer.borderWidth = 6
 
        urlItemsForOutfits.append(selectedItemForOutfit.selectedItems!)
        
        
        for url in urlItemsForOutfits {
            
            
            if url != url {
                
                fetchImage(imageURLStr: url, image: imageViewForItems)
                
                imageViewForItems.frame = CGRect(x: Int(stackViewForItm.bounds.minX) + 20, y: Int(stackViewForItm.bounds.minY) + 10, width: 100, height: 170)
                stackViewForItm.addSubview(imageViewForItems)
                imageViewForItems.addGestureRecognizer(penAction)
                
            }
        }
    }
    
    
    
    @IBAction func addNewItem(_ sender: Any) {
        
        let alertController = UIAlertController(title: "New item", message: "Add new item", preferredStyle: .alert)
        
        let add = UIAlertAction(title: "Add item", style: .default) {
            [self] _ in
            
            
            navigationController?.popToRootViewController(animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(add)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    
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

    @objc func dragging(penActions: UIPanGestureRecognizer) {
        let translation = penActions.translation(in: self.imageViewForItems)
        if let imageView = penActions.view {
            imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            penActions.setTranslation(.zero, in: self.imageViewForItems)
        }
    }
    
    
    
    @IBAction func saveOutfit(_ sender: Any) {
       
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
