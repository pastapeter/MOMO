//
//  Login.swift
//  MOMO
//
//  Created by 오승기 on 2021/10/10.
//

import UIKit

@IBDesignable
final class LoginViewController: UIViewController {
    
    @IBOutlet private weak var idTextField: MomoBaseTextField!
    @IBOutlet private weak var passwordTextField: MomoBaseTextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var passThroughButton: UIButton!
    @IBOutlet private weak var checkBoxView: UIView!
    @IBOutlet private weak var checkBoxLabel: UILabel!
    
    private let networkManager = NetworkManager()
    private var container = UIView()
    private var loadingView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idTextField.setBorderColor(to: .white)
        passwordTextField.setBorderColor(to: .white)
        idTextField.addLeftPadding(width: 10)
        passwordTextField.addLeftPadding(width: 10)
        checkBoxView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkBoxClicked)))
    }
    
    @objc func checkBoxClicked() {
        if checkBoxLabel.isHidden == false {
            checkBoxLabel.isHidden = true
            passwordTextField.isSecureTextEntry = true
        } else {
            checkBoxLabel.isHidden = false
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    private func showActivityIndicator() {
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    private func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    private func moveToHomeMainView() {
        DispatchQueue.main.async {
            //navigationbar없애야함.
            self.navigationController?.pushViewController(HomeMainViewController.loadFromStoryboard(), animated: false)
        }
    }
    
    private func failLogin() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "로그인실패",
                                          message: "아이디와 비밀번호를 확인해주세요",
                                          preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        guard let id = idTextField.text, let password = passwordTextField.text else {
            return
        }
        showActivityIndicator()
        let loginData = PostApi.login(email: id, password: password, contentType: .jsonData)
        networkManager.request(apiModel: loginData) { [weak self] networkResult in
            switch networkResult {
            case .success:
                self?.moveToHomeMainView()
            case .failure:
                self?.failLogin()
            }
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
            }
        }
    }
    
    @IBAction func didTapSignUpButton(_ sender: UIButton) {
        navigationController?.pushViewController(SignUpViewController.loadFromStoryboard(), animated: true)
    }
    
    @IBAction func didTapFindPasswordButton(_ sender: UIButton) {
        navigationController?.pushViewController(FindPasswordViewController.loadFromStoryboard(), animated: true)
    }
}

extension LoginViewController: StoryboardInstantiable { }
