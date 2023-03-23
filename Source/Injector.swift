import UIKit

internal struct Injector {
    /**
     Returns the javascript required to inject the Neeman CSS.
     
     - returns: The processed javascript.
     */
    func javascriptForCSS() -> String {
        var javascript = stringFromContentInFileName("InjectCSS.js")
        javascript = javascriptWithCSSAddedToJavascript(javascript!)
        javascript = javascriptWithVersionAddedToJavascript(javascript!)
        
        return javascript!
    }
    
    /**
     Returns the javascript with the "${CSS}" template replaced with the apps CSS.
     
     - parameter javascript: The javascript to add the CSS to.
     
     - returns: The processed javascript.
     */
    func javascriptWithCSSAddedToJavascript(_ javascript: String) -> String {
        var css = stringFromContentInFileName("WebView.css")
        css = css?.replacingOccurrences(of: "\n", with: "\\\n")
        
        return javascript.replacingOccurrences(of: "${CSS}", with: css!)
    }
    
    /**
     Returns the javascript with the "${VERSION}" template replaced with the current version of the app.
     
     - parameter javascript: The javascript to add the version to.
     
     - returns: The processed javascript.
     */
    func javascriptWithVersionAddedToJavascript(_ javascript: String) -> String {
        var versionForCSS = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionForCSS = version.replacingOccurrences(of: ".", with: "_")
        }
        
        return javascript.replacingOccurrences(of: "${VERSION}", with: versionForCSS)
    }
    
    /**
     Gets the content of the file with the specified name.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func stringFromContentInFileName(_ fileName: String) -> String! {
        return contentsOfMainBundlesFileWithName(fileName)
    }
    
    /**
     Gets the content of the file with the specified name from the Neeman bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfNeemansWithName(_ fileName: String) -> String {
        let bundle = Bundle(for: WebViewController.self)
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }
    
    /**
     Gets the content of the file with the specified name from the main bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfMainBundlesFileWithName(_ fileName: String) -> String {
        let bundle = Bundle.main
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }
    
    /**
     Gets the content of the file with the specified name from the specified bundle.
     
     - parameter fileName: The name of the file to load content from.
     - parameter bundle: The bundle in which to look for the named file.
     
     - returns: The contets of the file.
     */
    func contentsOfFileNamed(_ fileName: String, inBundle bundle: Bundle) -> String {
        if let path = bundle.path(forResource: fileName, ofType: "") {
            return contentsOfFileAtPath(path)
        }
        return ""
    }
    
    /**
     Gets the content of the file with the specified name from the specified path.
     
     - parameter filePath: The path to the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfFileAtPath(_ filePath: String) -> String {
        var content = ""
        do {
            content += try String(contentsOfFile:filePath, encoding: String.Encoding.utf8)
        } catch _ {
        }
        return content
    }
}
