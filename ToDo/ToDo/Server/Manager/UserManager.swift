//
//  UserManager.swift
//  Note
//
//  Created by LQ on 2022/1/31.
//

import Foundation
import LeanCloud

class UserManager: NSObject {
    
    static let shared = UserManager.init()
    private static let UserAccountsKey = "UserAccountsKey2"
    private static let UserLastLoginKey = "UserLastLoginKey2"
    private var userAccounts:[UserModel] = []
    var lastLoginUser:UserModel?
    var currentLoginUser:LCUser?
    
    override init() {
        if let arr = UserDefaults.standard.array(forKey: Self.UserAccountsKey) {
            for dict in arr {
                if let dict = dict as? Dictionary<String, String>, let email = dict["email"], let password = dict["password"] {
                    let model = UserModel.init(email: email, password: password)
                    userAccounts.append(model)
                }
            }
        }
        if let dict = UserDefaults.standard.dictionary(forKey: Self.UserLastLoginKey) as? Dictionary<String, String> {
            if let email = dict["email"], let password = dict["password"] {
                self.lastLoginUser = UserModel.init(email: email, password: password)
            }
        }
    }
    
    /*
    
    func checkToLogin(with completion:@escaping (() -> Void)) {
        if let lastLoginUser = self.lastLoginUser {
            self.rootViewController()?.view.makeToastActivity(.center)
            self.login(with: lastLoginUser.email, password: lastLoginUser.password) { error in
                self.rootViewController()?.view.hideToastActivity()
                if error != nil {
                    self.showLoginView(with: completion)
                } else {
                    self.rootViewController()?.view.makeSimpleToast("登录成功")
                    completion()
                }
            }
        } else {
            self.showLoginView(with: completion)
        }
    }
    
    func showRegisterView(with completion:@escaping (() -> Void)) {
        SwiftAlertView.show(title: "注册账号", message: nil, buttonTitles: ["注册"]) { alertView in
            alertView.addTextField { textField in
                textField.placeholder = "输入邮箱"
                textField.keyboardType = .emailAddress
            }
            alertView.addTextField { textField in
                textField.placeholder = "输入密码"
                textField.keyboardType = .asciiCapable
                textField.isSecureTextEntry = true
            }
            alertView.addTextField { textField in
                textField.placeholder = "验证密码"
                textField.keyboardType = .asciiCapable
                textField.isSecureTextEntry = true
            }
            
            alertView.isDismissOnActionButtonClicked = false
            alertView.isEnabledValidationLabel = true
            alertView.cancelButtonIndex = 1
        }.onActionButtonClicked { alertView, buttonIndex in
            let email = alertView.textField(at: 0)?.text ?? ""
            let password = alertView.textField(at: 1)?.text ?? ""
            let validate = alertView.textField(at: 2)?.text ?? ""
            
            if email.count == 0 {
                alertView.validationLabel.text = "未填写邮箱"
            } else if password.count == 0 {
                alertView.validationLabel.text = "未填写密码"
            } else if validate.count == 0 {
                alertView.validationLabel.text = "未填写验证密码"
            } else if !email.isValidEmail() {
                alertView.validationLabel.text = "邮箱格式错误"
            } else if password != validate {
                alertView.validationLabel.text = "密码不一致"
            } else {
                alertView.validationLabel.text = ""
                self.keyWinow()?.makeToastActivity(.center)
                self.signup(with: email, password: password) { error in
                    self.keyWinow()?.hideToastActivity()
                    if let error = error {
                        print(error)
                        alertView.validationLabel.text = error.localizedDescription
                    } else {
                        alertView.dismiss()
                        self.rootViewController()?.view.makeSimpleToast("注册成功")
                        self.showLoginView(with: completion)
                    }
                }
            }
        }
    }
    
    func showLoginView(with completion:@escaping (() -> Void)) {
        SwiftAlertView.show(title: "登录账号", message: nil, buttonTitles: ["去注册", "登录"]) { alertView in
            alertView.addTextField { textField in
                textField.placeholder = "输入邮箱"
                textField.keyboardType = .emailAddress
            }
            alertView.addTextField { textField in
                textField.placeholder = "输入密码"
                textField.keyboardType = .asciiCapable
                textField.isSecureTextEntry = true
            }
            
            alertView.isDismissOnActionButtonClicked = false
            alertView.isEnabledValidationLabel = true
            alertView.cancelButtonIndex = 2
        }.onActionButtonClicked { alertView, buttonIndex in
            if buttonIndex == 0 {
                alertView.dismiss()
                self.showRegisterView(with: completion)
                return
            }
            let email = alertView.textField(at: 0)?.text ?? ""
            let password = alertView.textField(at: 1)?.text ?? ""
            
            if email.count == 0 {
                alertView.validationLabel.text = "未填写邮箱"
            } else if password.count == 0 {
                alertView.validationLabel.text = "未填写密码"
            } else if !email.isValidEmail() {
                alertView.validationLabel.text = "邮箱格式错误"
            } else {
                alertView.validationLabel.text = ""
                self.keyWinow()?.makeToastActivity(.center)
                self.login(with: email, password: password) { error in
                    self.keyWinow()?.hideToastActivity()
                    if let error = error {
                        print(error)
                        alertView.validationLabel.text = error.localizedDescription
                    } else {
                        alertView.dismiss()
                        self.rootViewController()?.view.makeSimpleToast("登录成功")
                        completion()
                    }
                }
            }
        }
    }
    */
    
    func autoLogin() {
        if let lastLoginUser = self.lastLoginUser {
            self.login(with: lastLoginUser.email, password: lastLoginUser.password) { error in
                
            }
        }
    }
    
    func signup(with email:String, password:String, completion:@escaping((Error?)->Void)) {
        
        let user = LCUser()
        user.username = email.lcString
        user.password = password.lcString
        user.email = email.lcString
        
        user.signUp { result in
            switch result {
            case .success:
                self.verificationMain(email: email, completion: completion)
                break
            case .failure(let error):
                completion(error)
                break
            }
        }
    }
    
    func login(with email:String, password:String, completion:@escaping((Error?)->Void)) {
        LCUser.logIn(email: email, password: password) { result in
            switch result {
            case .success(object: let user):
                self.currentLoginUser = user
                self.saveUser(UserModel.init(email: email, password: password))
                completion(nil)
                break
            case .failure(error: let error):
                completion(error)
                break
            }
        }
    }
    
    func verificationMain(email: String, completion:@escaping((Error?)->Void)) {
        LCUser.requestVerificationMail(email: email) { result in
            switch result {
            case .success:
                completion(nil)
                break
            case .failure(let error):
                completion(error)
                break
            }
        }
    }
    
    private func saveUser(_ model:UserModel) {
        if !userAccounts.contains(model) {
            userAccounts.append(model)
        }
        self.lastLoginUser = model
        self.saveLocalData()
    }
    
    private func saveLocalData() {
        var accounts:[Dictionary<String,String>] = []
        for account in userAccounts {
            accounts.append(["email" : account.email, "password" : account.password])
        }
        UserDefaults.standard.set(accounts, forKey: Self.UserAccountsKey)
        
        if let lastLoginUser = self.lastLoginUser {
            let lastUser:Dictionary<String, String> = ["email" : lastLoginUser.email, "password" : lastLoginUser.password]
            UserDefaults.standard.set(lastUser, forKey: Self.UserLastLoginKey)
        }
        
    }
    
}
