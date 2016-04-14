//
// TableView
//

import UIKit
import Foundation

/**
 * 營養師列表
 */
class MemberList: UIViewController, PubClassDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    private var pubClass = PubClass()
    
    // HTTP 回傳資料設定 (Table data source)
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // SearchBar 相關
    private var searchActive : Bool = false
    private var aryNewMember: Array<Dictionary<String, AnyObject>> = []  // 搜尋結果的 array
    
    // 其他參數設定
    private var mMemberHttpData: MemberHttpData!  // http 連線取得會員全部資料
    private var strToday = ""
    private var currIndexPath: NSIndexPath?  // 目前 TableView 的 IndexPath
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mMemberHttpData = MemberHttpData(VC: self)
    }
    
    /**
     * viewWillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        if (bolReload != true) {
            // tableview reload
            self.tableData.reloadData()
            if let tmpIndexPath = self.currIndexPath {
                self.tableData.selectRowAtIndexPath(tmpIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }
    
    /**
     * viewDidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            bolReload = false
            reConnHTTP()
        }
    }
    
    /**
     * View Will Disappear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        searchBar.text = ""
        searchActive = false;
        aryNewMember = aryMember
    }
    
    /**
     * #mark: PubClassDelegate,  child 通知本頁面資料重整
     */
    func PageNeedReload(needReload: Bool) {
        if (needReload == true) {
            bolReload = true
        }
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "member"
        mParam["act"] = "member_getdata"
        
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
            let dictData = (dictRS["data"]!["content"]!)!
            
            self.strToday = dictData["today"] as! String
            
            // 設定會員資料 array data
            if let tmpData = dictData["data"] as? Array<Dictionary<String, AnyObject>> {
                self.aryMember = tmpData
            } else {
                self.aryMember = []
                self.currIndexPath = nil
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("member_nodataaddfirst"))
                
                return
            }
            
            // 加入原始的 position
            for i in (0..<self.aryMember.count) {
                self.aryMember[i]["position"] = i
            }
            
            self.aryNewMember = self.aryMember
            
            // tableview reload
            self.tableData.reloadData()
            if let tmpIndexPath = self.currIndexPath {
                self.tableData.selectRowAtIndexPath(tmpIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        })
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryNewMember.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryNewMember.count < 1) {
            return UITableViewCell()
        }
        
        let mCell: PubMemberSelectCell = tableView.dequeueReusableCellWithIdentifier("cellPubMemberList", forIndexPath: indexPath) as! PubMemberSelectCell
        
        let ditItem = aryNewMember[indexPath.row] as Dictionary<String, AnyObject>
        
        mCell.initView(ditItem)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 取得正確的 indexPath
        let mRow = aryNewMember[indexPath.row]["position"] as! Int
        let orgIndexPath = NSIndexPath(forRow: mRow, inSection: 0)

        // http 連線取得會員全部相關資料
        let strMemberId = aryNewMember[indexPath.row]["memberid"] as! String
        mMemberHttpData.connGetData(strMemberId, connCallBack: {
            (dictAllMemberData) -> Void in
            
            // 回傳資料失敗
            if (dictAllMemberData["result"] as! Bool != true) {
                var errMsg = dictAllMemberData["err"] as! String
                if (errMsg.characters.count < 1)  {
                    errMsg = self.pubClass.getLang("err_systemmaintain")
                }
                
                self.pubClass.popIsee(self, Msg: errMsg)
                
                return
            }
            
            // 回傳資料設定到傳送下個頁面
            self.currIndexPath = orgIndexPath
            self.performSegueWithIdentifier("MemberMain", sender: dictAllMemberData)
        })
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出確認視窗
            pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("member_delalertmsg")], withHandlerYes: {self.delMember(indexPath)}, withHandlerNo: {})
        }
        
        return
    }
    
    /**
     * 刪除會員程序
     */
    private func delMember(indexPath: NSIndexPath!) {
        searchBar.text = ""
        let strMemberId = aryNewMember[indexPath.row]["memberid"] as! String
        
        var dictArg0: Dictionary<String, String> = [:]
        dictArg0["id"] = strMemberId
        dictArg0["mode"] = "edit"
        dictArg0["del"] = "Y"
        
        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "member"
        dictParm["act"] = "member_senddata"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
        
        // HTTP 開始連線, 連線完成 aryMember 移除資料
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            let bolRS = dictHTTPSRS["result"] as! Bool
            let dictData = dictHTTPSRS["data"]!["content"]!
            var strMsg = self.pubClass.getLang("err_trylatermsg")
            
            if (bolRS == true) {
                strMsg = self.pubClass.getLang("datadelcompleted")
                if let strTmp = dictData!["msg"] as? String {
                    if (strTmp != "") {
                        strMsg = strTmp
                    }
                }
                
                // 刪除成功, 重新 http 連線重整頁面
                if (dictData!["isdel"] as! String == "Y") {
                    self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                        self.currIndexPath = nil
                        self.reConnHTTP()
                    })
                    
                    return
                }
            }
            
            self.pubClass.popIsee(self, Msg: strMsg)
        })
        
        return
    }
    
    /**
     * #mark: UISearchBar Delegate
     */
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    /**
     * #mark: UISearchBar Delegate
     * 搜尋字元改變時
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (aryMember.count < 1) {
            searchActive = false;
            return
        }
        
        // 沒有輸入字元
        if (searchText.isEmpty) {
            searchActive = false;
            searchBar.resignFirstResponder()
            
            aryNewMember = aryMember
            self.tableData.reloadData()
            
            return
        }
        
        // 比對字元, 比對欄位: membername, memberid, tel
        let aryField = ["membername", "memberid", "tel"]
        
        aryNewMember = aryMember.filter({ (dictItem: Dictionary<String, AnyObject>) -> Bool in
            
            for strField in aryField {
                if let strWord: String = dictItem[strField] as? String {
                    if strWord.lowercaseString.rangeOfString(searchText) != nil {
                        return true
                    }
                }
            }
            
            return false
        })
        
        if( aryNewMember.count == 0 ){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableData.reloadData()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員主頁面
        if (strIdent == "MemberMain") {
            let mDictData = sender as! Dictionary<String, AnyObject>
            let mVC = segue.destinationViewController as! MemberMain
            mVC.strToday = strToday
            mVC.dictAllData = mDictData
            mVC.dictMember = (mDictData["datamember"] as! Array<Dictionary<String, AnyObject>>)[0]
            mVC.delegate = self
            
            return
        }
        
        // 新增會員
        if (strIdent == "MemberAdd") {
            currIndexPath = nil
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "add"
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}