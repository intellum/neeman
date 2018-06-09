//
//  ErrorHandling.swift
//  Neeman
//
//  Created by Stephen Williams on 9/06/18.
//

import UIKit

internal struct ErrorHandling {
    func viewController() -> ErrorViewController {
        let storyboard = UIStoryboard(name: "Neeman", bundle: Bundle(for: WebViewController.self))
        return storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
    }
}
