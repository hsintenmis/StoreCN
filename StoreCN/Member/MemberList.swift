//
// TableView, UISearchBar, delegate 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 會員列表 + 新增刪除
 */
class MemberList: UIViewController, PubMemberListDelegate {
    
    // @IBOutlet
    @IBOutlet weak var containerMemberList: UIView!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    var reloadMemberList = true
    
    // HTTP 回傳資料設定
    private var aryMember: Array<Dictionary<String, AnyObject>> = []

    // 其他參數設定
    private var strToday = ""
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (!reloadMemberList) {
            return
        }
        
        // HTTP 連線取得資料
        StartHTTPConn()
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
        
        reloadMemberList = false
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * HTTP 連線取得資料
     */
    private func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "member";
        dictParm["act"] = "member_getdata";
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVCtrl, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     * 資料 key name：data, course, member 型態為 Array<Dictionary<String, AnyObject>>
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            dispatch_async(dispatch_get_main_queue(), {
                self.pubClass.popIsee(self.mVCtrl, Msg: self.pubClass.getLang(dictRS["msg"] as? String), withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
            
            return
        }
        
        /* 解析正確的 http 回傳結果，執行後續動作 */
        let dictData = (dictRS["data"]!["content"]!)!
        
        strToday = dictData["today"] as! String
        
        // 設定會員資料 array data
        if let tmpData = dictData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        } else {
            pubClass.popIsee(mVCtrl, Msg: pubClass.getLang("member_nodataaddfirst"))
            
            return
        }
        
        // !! container 直接加入 'PubMemberList'
        let mPubMemberList = storyboard!.instantiateViewControllerWithIdentifier("PubMemberList") as! PubMemberList
        
        mPubMemberList.delegate = self
        mPubMemberList.aryMember = aryMember
        
        let mView = mPubMemberList.view
        mView.frame.size.height = containerMemberList.layer.frame.height
        
        self.containerMemberList.addSubview(mView)
        self.navigationController?.pushViewController(mPubMemberList, animated: true)
    }
    
    /**
    * #mark: PubMemberListDelegate, 會員列表，點取會員執行相關程序
    */
    func CellClick(MemberData dictData: Dictionary<String, AnyObject>) {
        self.performSegueWithIdentifier("MemberData", sender: dictData)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier

        if (strIdent == "MemberData") {
            /*
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "edit"
            */
            
            return
        }
        
        if (strIdent == "MemberAdd") {
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "add"
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '新增' button
     */
    @IBAction func actAdd(sender: UIBarButtonItem) {
        
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

