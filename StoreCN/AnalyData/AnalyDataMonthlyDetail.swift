//
// with ContainerView, add sub VC to ContainerView
//

import UIKit
import Foundation

/**
 * 指定的'月份'銷售總覽, '每月收入' Item click 進入本頁
 */
class AnalyDataMonthlyDetail: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    var pubClass: PubClass!
    
    // public, parent 傳入
    var strYYMMDD: String!  // 指定日期， parent 設定
    
    // ContainerView 相關參數
    private var mAnalyDataToday: AnalyDataToday!
    
    // 其他參數
    private var strToday: String!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // '今日收入' VC
        mAnalyDataToday = self.storyboard?.instantiateViewControllerWithIdentifier("AnalyDataToday") as! AnalyDataToday
        
        self.mAnalyDataToday.strYYMMDD = strYYMMDD
    }
    
    override func viewDidAppear(animated: Bool) {
        reConnHTTP()
    }
    
    /**
     * HTTP 重新連線取得資料, '今日收入'
     */
    private func reConnHTTP() {
        // http 連線參數
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "analydata"
        mParam["act"] = "analydata_today"
        mParam["arg0"] = strYYMMDD
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            self.strToday = dictData["today"] as! String
            
            // 產生對應的 VC
            self.mAnalyDataToday.dictAllData = dictData
            self.mAnalyDataToday.strToday = self.strToday
            
            // VC view 加入到 container View
            let mView = self.mAnalyDataToday.view
            mView.frame.size.height = self.containView.layer.frame.height
            mView.frame.size.width = self.containView.layer.frame.width
            
            self.containView.addSubview(mView)
        })
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}