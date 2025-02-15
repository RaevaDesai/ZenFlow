//
//  ViewController.swift
//  ZenFlow
//
//  Created by Swarasai Mulagari on 2/15/25.
//

import UIKit
import SwiftUI
import CoreML

class ViewController: UIViewController {
    private var shouldShowOptions = false {
        didSet {
            updateUI()
        }
    }
    private var formHostingController: UIHostingController<HealthFormView>?
    private var optionsHostingController: UIHostingController<OptionsView>?
    private var splashScreenHostingController: UIHostingController<SplashScreenView>?
    
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "MarkerFelt-Wide", size: 24)
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1)
        label.text = ""
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.784, green: 0.894, blue: 0.937, alpha: 1)
        
        showSplashScreen {
            self.showHealthForm()
            self.setupUIElements()
        }
    }
    
    private func showSplashScreen(completion: @escaping () -> Void) {
        let splashScreenView = SplashScreenView()
        splashScreenHostingController = UIHostingController(rootView: splashScreenView)
        
        if let hostingController = splashScreenHostingController {
            addChild(hostingController)
            hostingController.view.frame = view.bounds
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.splashScreenHostingController?.view.removeFromSuperview()
            self.splashScreenHostingController?.removeFromParent()
            completion()
        }
    }
    
    private func showHealthForm() {
        let formView = HealthFormView(
            shouldShowOptions: shouldShowOptions,
            onShouldShowOptionsChange: { [weak self] newValue in
                self?.shouldShowOptions = newValue
            },
            onSubmit: { [weak self] optionsView in
                self?.navigateToOptions(optionsView: optionsView)
            }
        )
        
        formHostingController = UIHostingController(rootView: formView)
        if let hostingController = formHostingController {
            addChild(hostingController)
            hostingController.view.frame = view.bounds
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
    }
    
    private func updateUI() {
        
    }
    
    private func navigateToOptions(optionsView: OptionsView) {
        print("Name in ViewController before presenting: \(optionsView.name)")
        self.optionsHostingController = UIHostingController(rootView: optionsView)
        if let hostingController = self.optionsHostingController {
            self.addChild(hostingController)
            hostingController.view.frame = self.view.bounds
            self.view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
        }
    }
    
    
    private func setupUIElements() {
        view.addSubview(resultLabel)
        view.addSubview(backButton)
        
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
       
        
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    @objc private func backButtonTapped() {
        print("Back button tapped")
    }
}

