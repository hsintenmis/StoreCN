//
// TableView, UISearchBar, delegate 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 會員列表 + 新增刪除
 */
class MemberList: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // HTTP 回傳資料設定
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // SearchBar 相關
    private var searchActive : Bool = false
    private var aryNewMember: Array<Dictionary<String, AnyObject>> = []  // 搜尋結果的 array
    
    // 其他參數設定
    private var strToday = ""
    private var newIndexPath: NSIndexPath!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
        
        newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // HTTP 連線取得資料
        StartHTTPConn()
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
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
        
        // 設定回傳資料, 若無會員跳轉新增頁面
        
        // 本頁面資料重整
        aryNewMember = aryMember
        tableData.reloadData()
        
        // 移動到指定Item
        //tableData.selectRowAtIndexPath(newIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryNewMember.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryNewMember.count < 1) {
            return nil
        }
        
        let mCell: MemberListCell = tableView.dequeueReusableCellWithIdentifier("cellMemberList", forIndexPath: indexPath) as! MemberListCell
        
        let ditItem = aryNewMember[indexPath.row] as Dictionary<String, AnyObject>
        let strGender = pubClass.getLang("gender_" + (ditItem["gender"] as! String))
        let strAge = (ditItem["age"] as! String) + pubClass.getLang("name_age")
        
        mCell.labName.text = ditItem["membername"] as? String
        mCell.labId.text = ditItem["memberid"] as? String
        mCell.labGender.text = strGender + " " + strAge
        mCell.labTel.text = ditItem["tel"] as? String
        
        mCell.labJoin.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: "8s")
        mCell.labBirth.text = pubClass.formatDateWithStr(ditItem["birth"] as! String, type: "8s")
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            
            return
        }
    }
    
    /**
    * #mark: UISearchBar Delegate
    */
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
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
            aryNewMember = aryMember
            self.tableData.reloadData()
            
            return
        }
        
        // 比對字元, 比對欄位: membername, memberid, tel
        let aryField = ["membername", "memberid", "tel"]
    
        aryNewMember = aryMember.filter({ (dictItem) -> Bool in
            for strField in aryField {
                if let strWord: NSString = dictItem[strField] as! String {
                    if (strWord.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound) {
                        
                        return true
                    }
                }
            }
            
            return false
        })
        
        if(aryNewMember.count == 0){
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
        
        if (strIdent == "MemberAd") {
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

