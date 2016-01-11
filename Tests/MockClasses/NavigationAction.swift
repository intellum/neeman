import WebKit
import Neeman

class NavigationAction: WKNavigationAction {
    var myRequest: NSURLRequest
    override var request: NSURLRequest {
        get {
            return myRequest
        }
    }
    override var navigationType: WKNavigationType {
        get {
            return .LinkActivated
        }
    }
    init(request: NSURLRequest) {
        myRequest = request
    }
}
