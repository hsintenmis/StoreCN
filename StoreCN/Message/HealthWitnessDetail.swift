//
// WebView
// URL 網址如：
// publicsh.hsinten.com.tw/storecn/
// ?acc=XXX&psd=XXX&po=news&op=company&fm_data[id]=jobj["id"]
//

import UIKit
import Foundation

/**
 * 官網新訊詳細內容 class,
 */
class HealthWitnessDetail: UIViewController {
    
    @IBOutlet weak var webviewImg: UIWebView!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    
    // common property
    private var pubClass: PubClass!
    
    // public, 從 parent 設定
    var dictData: Dictionary<String, String>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        labTitle.text = dictData["title"]
        webviewImg.scalesPageToFit = true
        webviewImg.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func viewDidAppear(animated: Bool) {
        // WebView 設定
        let strURL = pubClass.D_WEBURL + dictData["filename"]!
        let nsURL = strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let request = NSURLRequest(URL: NSURL(string: nsURL!)!)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.webviewImg.loadRequest(request)
        })
    }
    
    /** WebView delegate Start */
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        
        pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType)->Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        viewLoading.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        viewLoading.stopAnimating()
    }
    /** WebView delegate End */
     
     /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}