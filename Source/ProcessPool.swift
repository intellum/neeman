import WebKit

public class ProcessPool {
    public static var mockProcessPool: WKProcessPool?
    static var processPool = WKProcessPool()
    public static var sharedInstance: WKProcessPool {
        get {
            return mockProcessPool ?? processPool
        }
    }
}
