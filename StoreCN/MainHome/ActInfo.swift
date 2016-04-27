//
// Webview
//

import UIKit
import Foundation

/**
 * 店家活動專區 WebView
 */
class ActInfo: UIViewController {
    // web 連線固定參數
    private var strURL = "?data[acc]=%@&data[psd]=%@"
    
    // @IBOutlet
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    @IBOutlet weak var labLoading: UILabel!
    @IBOutlet weak var navybarTop: UINavigationBar!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 設定
    var dictAllData: Dictionary<String, AnyObject>!
    var strToday: String!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navybarTop.topItem!.title = dictAllData["title"] as? String
        
        // WebView 設定
        strURL = (dictAllData["url"] as! String) + strURL
        strURL = String(format: strURL, arguments: [pubClass.getAppDelgVal("V_USRACC") as! String, pubClass.getAppDelgVal("V_USRPSD") as! String])
        
        let request = NSURLRequest(URL: NSURL(string: strURL)!)
        self.webView.loadRequest(request)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /** WebView delegate Start */
    
    /**
     * #mark: WebView delegate
     */
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        //print("Webview fail with error \(error)");
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType)->Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        labLoading.alpha = 1.0
        viewLoading.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        labLoading.alpha = 0.0
        viewLoading.stopAnimating()
        //print("Webview did finish load")
    }
    /** WebView delegate End */
    
    /**
     * act, 點取 '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
