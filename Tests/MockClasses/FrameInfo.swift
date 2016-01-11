import WebKit

class FrameInfo: WKFrameInfo {
    var myRequest: NSURLRequest
    override var request: NSURLRequest {
        get {
            return myRequest
        }
    }
    init(request: NSURLRequest) {
        myRequest = request
    }
}
