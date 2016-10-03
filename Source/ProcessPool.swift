import WebKit

/** This is used to allow us to share a process pool between our web views.
It allows cookies to be shared between each instance of a web view.
*/
open class ProcessPool {
    /// The global instance of the process pool.
    open static var sharedInstance = WKProcessPool()
    
    /// Recreates the process pool. This is usefull when logging out to get rid of cookies.
    open static func reset() {
        sharedInstance = WKProcessPool()
    }
}
