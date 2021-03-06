//
//  SignUpWithEmailViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/29/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth

enum SignUpError: Error {
    case noUserNameOrPasswordError
    case noMatchingPasswordError
}

extension SignUpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noUserNameOrPasswordError:
            return NSLocalizedString("Text fields should not be empty", comment: "SignUp error")
        case .noMatchingPasswordError:
            return NSLocalizedString("Passwords don't match. Please double check your password", comment: "SignUp error")
        }
    }
}

class SignUpWithEmailViewController: UIViewController {
    
    // MARK: Properties
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
        setupActivityIndicator()
    }
    
    func setupActivityIndicator() {
        
        // Activity Indicator Setup
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    
    // MARK: Signup
    @IBAction func signUpPressed(_ sender: Any) {
        
        userDidTapView(self)
        self.activityIndicator.startAnimating()
        
        guard let username = usernameTextField.text, let password = passwordTextField.text, let confirmedPassword = confirmPasswordTextField.text else {
            self.activityIndicator.stopAnimating()
            self.showAlertWithError(title: "Sign up Failed", error: SignUpError.noUserNameOrPasswordError)
            return
        }
        
        
        if password == confirmedPassword {
            
            setUIEnabled(false)
            
            Auth.auth().createUser(withEmail: username, password: password) { (user, error) in
                
                performUIUpdatesOnMain {
                    if (user != nil) {
                        self.activityIndicator.stopAnimating()
                        self.completeSignup()
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.showAlertWithError(title: "Sign up Error", error: error!)
                    }
                }
            }
        } else {
            self.activityIndicator.stopAnimating()
            self.showAlertWithError(title: "Sign up Failed", error: SignUpError.noMatchingPasswordError)
        }
    }
    
    
    func completeSignup() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            self.dismiss(animated: false, completion: {
                self.navigationController!.popToRootViewController(animated: true)
            })
        }
    }
    
}

// MARK: - SignUpWithEmailViewController: UITextFieldDelegate

extension SignUpWithEmailViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification) - 80
            // logoImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
            // logoImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
        resignIfFirstResponder(confirmPasswordTextField)
    }
    
    
}

// MARK: - SignUpWithEmailViewController (Configure UI)

extension SignUpWithEmailViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        confirmPasswordTextField.isEnabled = enabled
        signUpButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            signUpButton.alpha = 1.0
        } else {
            signUpButton.alpha = 0.5
        }
    }
}

// MARK: - SignUpWithEmailViewController (Notifications)

private extension SignUpWithEmailViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
