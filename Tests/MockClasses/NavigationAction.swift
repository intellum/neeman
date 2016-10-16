import WebKit
import Neeman

class NavigationAction: WKNavigationAction {
    var myRequest: URLRequest
    override var request: URLRequest {
        get {
            return myRequest
        }
    }
    override var navigationType: WKNavigationType {
        get {
            return .linkActivated
        }
    }
    init(request: URLRequest) {
        myRequest = request
    }
}
