//
//  WebViewController+Restoration.swift
//  Pods
//
//  Created by Stephen Williams on 31/05/16.
//
//

extension WebViewController {
    var encodingKeyURLString: String { get { return "urlString" } }

    /**
     Save the data required to restore when entering the background.
     
     - parameter coder: The NSCoder object provided by iOS to save the data with.
     */
    override open func encodeRestorableState(with coder: NSCoder) {
        if let urlString = URLString {
            coder.encode(urlString, forKey: encodingKeyURLString)
        }
        super.encodeRestorableState(with: coder)
    }
    
    /**
     Restore the data that we have saved to restore when resuming the app.
     
     - parameter coder: The NSCoder object provided by iOS in which the data was saved when backgrounding the app.
     */
    override open func decodeRestorableState(with coder: NSCoder) {
        if let urlString = coder.decodeObject(forKey: encodingKeyURLString) as? String {
            URLString = urlString
            loadURL(rootURL)
        }
        
        super.decodeRestorableState(with: coder)
    }
}
