//
//  ViewController.swift
//  Daywear
//
//  Created by Ann Prudnikova on 8.02.23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    var ref: DatabaseReference!

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var appNameLbl: UILabel!
    
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //#colorLiteral()
        
        view.backgroundColor = #colorLiteral(red: 0.9905706048, green: 0.8760409168, blue: 0.6444740729, alpha: 1)
        backgroundView.backgroundColor = #colorLiteral(red: 0.8966694327, green: 0.7454180396, blue: 0.5850306072, alpha: 1)
        backgroundView.alpha = 0.6
        backgroundView.layer.cornerRadius = 30
        appNameLbl.text = "DayWear \nApp"
        appNameLbl.layer.borderColor = UIColor.purple.cgColor
        warnLabel.text = "Error"
        warnLabel.textColor = .red
        warnLabel.alpha = 0
        signInBtn.setTitle("Sign In", for: .normal)
        signUpBtn.setTitle("Sign Up", for: .normal)
        emailTF.placeholder = "Please enter e-mail"
        emailTF.keyboardType = .emailAddress
        emailTF.textContentType = .emailAddress
        passwordTF.placeholder = "Please enter password"
        passwordTF.textContentType = .password
        passwordTF.isSecureTextEntry = true
        
        ref = Database.database().reference(withPath: "users")

        // если у нас еще есть действующий user то сделаем переход
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let _ = user else {
                return
            }
            guard let tvc = self?.storyboard?.instantiateViewController(withIdentifier: "ClothingListCVC") as? UINavigationController else {return}
            tvc.modalPresentationStyle = .overFullScreen
            self?.present(tvc, animated: false)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // чистим поля
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }

    @IBAction func signInAction(_ sender: Any) {
        // проверяем все поля
        guard let email = emailTF.text,
              let password = passwordTF.text,
              email != "",
              password != "" else {
            // показываем уникальный error
            displayWarningLabel(withText: "Info is incorrect")
            return
        }

        // логинемся
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let error {
                self?.displayWarningLabel(withText: "Error ocured: \(error.localizedDescription)")
            } else if let _ = user {
                // переходим на новый экран
                guard let tvc = self?.storyboard?.instantiateViewController(withIdentifier: "ClothingListCVC") as? UINavigationController else {return}
                tvc.modalPresentationStyle = .overFullScreen
                self?.present(tvc, animated: true)
                return
            } else {
                self?.displayWarningLabel(withText: "No such user")
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        // проверяем все поля
        guard let email = emailTF.text, let password = passwordTF.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        // createUser
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "Registration was incorrect\n\(error.localizedDescription)")
            } else {
                guard let user = user else {
                    return
                }
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
               
            }
        }
    }
    
    // MARK: Private

     private func displayWarningLabel(withText text: String)
    {
        warnLabel.text = text
        UIView.animate(withDuration: 5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut, // плавно появляется и плавно исчезает
                       animations: { [weak self] in
                           self?.warnLabel.alpha = 1
                       }) { [weak self] _ in
            self?.warnLabel.alpha = 0
        }
    }
    
    @objc func kbDidShow(notification: Notification) {
        self.view.frame.origin.y = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= (keyboardSize.height / 2)
        }
    }
    
    @objc func kbDidHide() {
        self.view.frame.origin.y = 0
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

