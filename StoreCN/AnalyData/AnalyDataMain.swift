//
// with ContainerView, add sub VC to ContainerView
// subViewController 以 storyboard 的 resourceident 實體化產生
//
// 本頁面執行 http 連線取得資料傳送給　child class
//

import UIKit
import Foundation

/**
 * 收入分析主頁面
 */
class AnalyDataMain: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var navybarView: UINavigationBar!
    
    // common property
    var pubClass: PubClass!
    
    // http 連線參數
    private var httpParm: Dictionary<String, String> = [:]
    
    // ContainerView 相關參數
    private var aryChildVC: Array<UIViewController> = []
    private let aryVCIdent = ["today", "daily", "monthly"]
    
    private var mAnalyDataToday: AnalyDataToday!
    private var mAnalyDataDaily: AnalyDataDaily!
    private var mAnalyDataMonthly: AnalyDataMonthly!
    
    // 其他參數
    private var strToday: String!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // http 連線參數
        httpParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        httpParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        httpParm["page"] = "analydata"

        // child VC
        mAnalyDataToday = self.storyboard?.instantiateViewControllerWithIdentifier("AnalyDataToday") as! AnalyDataToday
        mAnalyDataDaily = self.storyboard?.instantiateViewControllerWithIdentifier("AnalyDataDaily") as! AnalyDataDaily
        mAnalyDataMonthly = self.storyboard?.instantiateViewControllerWithIdentifier("AnalyDataMonthly") as! AnalyDataMonthly
    }
    
    override func viewDidAppear(animated: Bool) {
        reConnHTTP(aryVCIdent[0], strYYMMDD: nil)
    }
    
    /**
     * HTTP 重新連線取得資料, '今日收入'
     */
    private func reConnHTTP(strAct: String!, strYYMMDD: String?) {
        // Request 參數設定
        var mParam = httpParm
        //mParam["act"] = "analydata_today"
        mParam["act"] = "analydata_" + strAct
        
        if (strYYMMDD != nil) {
            mParam["arg0"] = strYYMMDD
        }
        
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
            var mView: UIView!
            
            if (strAct == "today") {
                self.mAnalyDataToday.dictAllData = dictData
                self.mAnalyDataToday.strToday = self.strToday
                if (strYYMMDD != nil) {
                    self.mAnalyDataToday.strYYMMDD = strYYMMDD
                }

                mView = self.mAnalyDataToday.view
            }
            else if (strAct == "daily") {
 
                mView = self.mAnalyDataDaily.view
            }
            else {
                mView = self.mAnalyDataMonthly.view
            }
            
            mView.frame.size.height = self.containView.layer.frame.height
            mView.frame.size.width = self.containView.layer.frame.width
            
            /*
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMoveToParentViewController(self)
            */
            
            self.containView.addSubview(mView)
        })
    }
    
    /**
     * act, Segment 子選單，今日/每日/每月 VC 產生加入 containerView
     */
    @IBAction func actSubMenu(sender: UISegmentedControl) {
        reConnHTTP(aryVCIdent[sender.selectedSegmentIndex], strYYMMDD: nil)
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}