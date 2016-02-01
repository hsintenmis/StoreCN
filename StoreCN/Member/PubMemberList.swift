//
// TableView, UISearchBar, delegate 直接從 storyboard 設定
//

/**
 * protocol, PubMemberList Delegate
 */
protocol PubMemberListDelegate {
    /**
    * Table Cell 點取，點取指定會員，實作點取後相關程序
    */
    func CellClick(MemberData dictData: Dictionary<String, AnyObject>)
}

import UIKit
import Foundation

/**
 * 會員列表 公用
 */
class PubMemberList: UIViewController {
    var delegate = PubMemberListDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    
    // Table DataSource, 會員全部資料
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
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
        newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        aryNewMember = aryMember
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
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
        
        let mCell: PubMemberListCell = tableView.dequeueReusableCellWithIdentifier("cellPubMemberList", forIndexPath: indexPath) as! PubMemberListCell
        
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
        
        print(editingStyle)
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            
            return
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.CellClick(MemberData: aryNewMember[indexPath.row])
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
    
}

