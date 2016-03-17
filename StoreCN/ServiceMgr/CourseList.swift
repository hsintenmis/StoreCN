//
// Container, 使用 addSubview 加入公用的 tableview class
//

import UIKit
import Foundation

/**
 * 會員已購買療程列表, 本頁面直接 http 連線取得資料
 */
class Courselist: UIViewController, PubClassDelegate {
    
    // @IBOutlet
    @IBOutlet weak var contviewList: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 已購買的療程列表, 公用 class
    private var mPubCourseSelect: PubCourseSelect!
    
    // 其他參數
    private var bolReload = true
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始, 已購買的療程選擇, 公用 class
        mPubCourseSelect = storyboard!.instantiateViewControllerWithIdentifier("PubCourseSelect") as! PubCourseSelect
        mPubCourseSelect.delegate = self
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        /*
        if (bolReload == true) {
            bolReload = false
            reConnHTTP()
        }
        */
        // !! container 直接加入 'PubMemberList'
        let mView = self.mPubCourseSelect.view
        mView.frame.size.height = self.contviewList.layer.frame.height
        self.contviewList.addSubview(mView)
        self.navigationController?.pushViewController(self.mPubCourseSelect, animated: true)
    }
    
    /**
     * #mark: PubClassDelegate
     * Page 重整
     */
    func PageNeedReload(needReload: Bool) {
        bolReload = needReload
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "cardmanage"
        mParam["act"] = "cardmanage_getdata"
        
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
            self.mPubCourseSelect.dictAllData = dictData

            // !! container 直接加入 'PubMemberList'
            let mView = self.mPubCourseSelect.view
            mView.frame.size.height = self.contviewList.layer.frame.height
            self.contviewList.addSubview(mView)
            self.navigationController?.pushViewController(self.mPubCourseSelect, animated: true)
        })
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}