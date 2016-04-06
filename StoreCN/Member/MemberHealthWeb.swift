//
// Webview
//

import UIKit
import Foundation

/**
 * 會員健康紀錄 chart 圖表
 */
class MemberHealthWeb: UIViewController {
    // web 連線固定參數
    //private var D_URL_HEALTHLIST = "&po=health&op=health_list";
    private var D_URL_HEALTHANALY = "&po=stats";
    
    // @IBOutlet
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    @IBOutlet weak var labLoading: UILabel!
    
    // common property
    var pubClass = PubClass()
    
    // public, parent 設定
    var strMemberId: String!
    var strMemberPsd: String!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WebView 設定
        let strURL = pubClass.D_CNWWWURL + "?acc=" + strMemberId + "&psd=" + strMemberPsd + D_URL_HEALTHANALY
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
