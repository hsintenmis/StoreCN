//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 會員購貨紀錄列表, 公用 class
 */
class PubMemberPurchaseSelect: UITableViewController, PubClassDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 設定
    var aryPurchaseData: Array<Dictionary<String, AnyObject>> = []
    var strMemberId: String!
    var strToday = ""
    var mParent: MemberMainPager!
    
    // 其他參數設定
    private var mSaleDetail: SaleDetail!
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 顯示'無資料'
        self.labNoData.alpha = (self.aryPurchaseData.count < 1) ? 1.0 : 0.0
    }
    
    /**
    * HTTP 重新連線取得資料
    */
    private func reConnHTTP() {
        // HTTP 連線取得該會員全部資料(course, mead, soqibed, purchase)
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getdata"
        dictParm["arg0"] = strMemberId
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤顯示錯誤訊息
            if (dictRS["result"] as! Bool != true) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: self.pubClass.getLang(dictRS["msg"] as? String))
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = (dictRS["data"]!["content"]!)!
            
            // parent 'MemberMainPager' 的 dictAllData 重設
            self.mParent.dictAllData = dictData as! Dictionary<String, AnyObject>
            
            // 重設本頁面 'aryPurchaseData'
            if let tmpDict = dictData["purchase"] as? Array<Dictionary<String, AnyObject>> {
                self.aryPurchaseData = tmpDict
            } else {
                self.aryPurchaseData = []
            }
            
            // 本頁面資料有變動, TableView Reload
            self.tableData.reloadData()
            if let tmpIndexPath = self.currIndexPath {
                self.tableData.selectRowAtIndexPath(tmpIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            // 顯示'無資料'
            self.labNoData.alpha = (self.aryPurchaseData.count < 1) ? 1.0 : 0.0
        })
    }
    
    /**
     * #mark: PubClassDelegate
     * page reload
     */
    func PageNeedReload(needReload: Bool) {
        // 重新連線 HTTP 取得資料
        if (needReload == true) {
            reConnHTTP()
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryPurchaseData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryPurchaseData.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = aryPurchaseData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPubMemberPurchaseSelect", forIndexPath: indexPath) as! PubMemberPurchaseSelectCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        
        // 跳轉 'SaleDetail' storyboard
        let storyboard = UIStoryboard(name: "SaleDetail", bundle: nil)
        mSaleDetail = storyboard.instantiateViewControllerWithIdentifier("SaleDetail") as! SaleDetail
        mSaleDetail.strToday = self.strToday
        mSaleDetail.dictAllData = aryPurchaseData[indexPath.row]
        mSaleDetail.delegate = self
        
        self.presentViewController(mSaleDetail, animated: true, completion: nil)
        
        return
    }
    
}

