//
// static TableView
//

import UIKit
import Foundation

/**
 * 會員健康紀錄選單，瀏覽紀錄，記錄分析
 */
class MemberHealth: UITableViewController {
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    // common property
    var pubClass = PubClass()
    
    // public, parent 設定
    var dictMember: Dictionary<String, AnyObject>!
    
    // 會員資料
    private var strMemberId: String!
    private var strMemberPsd: String!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        strMemberId = dictMember["memberid"] as! String
        strMemberPsd = dictMember["psd"] as! String
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 健康管理, 月曆顯示
        if (strIdent == "HealthCalendar") {
            let mVC = segue.destinationViewController as! HealthCalendar
            mVC.dictMember = dictMember
            
            return
        }
        
        // 健康紀錄 WebView
        if (strIdent == "MemberHealthWeb") {
            let mVC = segue.destinationViewController as! MemberHealthWeb
            mVC.strMemberId = strMemberId
            mVC.strMemberPsd = strMemberPsd
            
            return
        }
        
        return
    }
    
}