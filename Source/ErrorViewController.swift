//
//  ErrorViewController.swift
//  Neeman
//
//  Created by Stephen Williams on 23/02/16.
//
//

import UIKit

class ErrorViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var error: NetworkError? = nil {
        didSet {
            label.text = error?.description
            imageView.image = UIImage(named: "Error-HTTP", in: Bundle.main, compatibleWith: nil)
                ?? UIImage(named: "Error-HTTP", in: Bundle(for: WebViewController.self), compatibleWith: nil)
        }
    }
}
