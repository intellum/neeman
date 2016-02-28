//
//  NeemanLocalizedString.swift
//  Neeman
//
//  Created by Stephen Williams on 23/02/16.
//
//

import Foundation

internal func NeemanLocalizedString(key: String, comment: String?) -> String {
    struct Static {
        static let bundle = NSBundle(forClass: WebViewController.self)
    }
    let mainBundleString = NSLocalizedString(key, bundle: NSBundle.mainBundle(), comment: comment ?? "")
    if mainBundleString == key {
        return NSLocalizedString(key, tableName: "Neeman", bundle: Static.bundle, value: key, comment: comment ?? "")
    }
    return mainBundleString
}