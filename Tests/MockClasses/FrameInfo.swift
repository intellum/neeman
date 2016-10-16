import WebKit

class FrameInfo: WKFrameInfo {
    var myRequest: URLRequest
    override var request: URLRequest {
        get {
            return myRequest
        }
    }
    init(request: URLRequest) {
        myRequest = request
    }
}
