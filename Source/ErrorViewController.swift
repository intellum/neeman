//
//  ErrorViewController.swift
//  Neeman
//
//  Created by Stephen Williams on 23/02/16.
//
//

import UIKit

class ErrorViewController: UIViewController {
    var imageView: UIImageView!
    var label: UILabel!
    
    var error: NetworkError? = nil {
        didSet {
            label.text = error?.description
            imageView.image = UIImage(named: "Error-HTTP", in: Bundle.main, compatibleWith: nil)
                ?? UIImage(named: "Error-HTTP", in: Bundle(for: WebViewController.self), compatibleWith: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView()
        label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 240)
        ])

    }
}
