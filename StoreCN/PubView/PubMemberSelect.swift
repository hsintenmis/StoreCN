//
// TableView, UISearchBar, delegate 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * protocol, PubMemberList Delegate
 */
protocol PubMemberSelectDelegate {
    /**
     * Table Cell 點取，點取指定會員，實作點取後相關程序
     */
    func MemberSelected(MemberData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath)
}

/**
 * 顯示會員大頭照, from URL 圖片, UIImageView extension
 */
extension UIImageView {
    func downloadImageFrom(link link:String, contentMode: UIViewContentMode) {
        NSURLSession.sharedSession().dataTaskWithURL( NSURL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
                
                var hasImg = false;
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (Int(httpResponse.statusCode) == 200) {
                        hasImg = true
                    }
                }
                
                if (!hasImg) {
                    self.image = UIImage(named: "user_empty01.png")
                }
                
            }
        }).resume()
    }
}

/**
 * 會員選擇 公用 class
 */
class PubMemberSelect: UIViewController {
    var delegate = PubMemberSelectDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    let pubClass = PubClass()
    
    // Table DataSource, 會員全部資料, parent 設定
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var currIndexPath: NSIndexPath?
    
    // SearchBar 相關
    private var searchActive : Bool = false
    private var aryNewMember: Array<Dictionary<String, AnyObject>> = []  // 搜尋結果的 array
    
    // 其他參數設定
    private var strToday = ""
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加入原始的 position
        for i in (0..<aryMember.count) {
            aryMember[i]["position"] = i
        }
        
        aryNewMember = aryMember
    }
    
    /**
     * View WiiAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        if let tmpIndexPath = currIndexPath {
            tableData.reloadData()
            tableData.selectRowAtIndexPath(tmpIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
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
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
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
        let mIndexPath = NSIndexPath(forRow: mRow, inSection: 0)
        
        currIndexPath = mIndexPath
        delegate?.MemberSelected(MemberData: aryNewMember[indexPath.row], indexPath: mIndexPath)
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
    
}