//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 會員購貨紀錄列表, parent 'MemberMainPager', 由會員主頁面轉入
 */
class SaleList: UITableViewController, PubClassDelegate {
    // delegate, 會員主頁面資料變動
    var delegate = MemberHttpDataDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 設定
    var aryPurchaseData: Array<Dictionary<String, AnyObject>> = []
    var strMemberId: String!
    var strToday = ""
    
    // 其他參數設定
    private var mMemberHttpData: MemberHttpData!  // http 連線取得會員全部資料
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mMemberHttpData = MemberHttpData(VC: self)
        
        // 顯示'無資料'
        self.labNoData.alpha = (self.aryPurchaseData.count < 1) ? 1.0 : 0.0
    }
    
    /**
     * #mark: PubClassDelegate,
     * 重新 http 連線取得資料，本頁面 table reload, 通知 parent 資料變動
     */
    func PageNeedReload(needReload: Bool) {
        if (needReload != true) {
            return
        }
        
        // http 連線取得會員全部相關資料
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
            
            // 回傳資料成功，本頁面 table reload
            self.strToday = dictAllMemberData["today"] as! String
            
            if let aryTmp = dictAllMemberData["purchase"] as? Array<Dictionary<String, AnyObject>> {
                self.aryPurchaseData = aryTmp
                self.labNoData.alpha = 0.0
            } else {
                self.aryPurchaseData = []
                self.labNoData.alpha = 1.0
            }
            
            self.tableData.reloadData()
            if (self.currIndexPath != nil) {
                self.tableData.selectRowAtIndexPath(self.currIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            // 通知上層須要更新資料
            self.delegate?.UpDateMemberAllData(dictAllMemberData)
        })
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSaleList", forIndexPath: indexPath) as! SaleListCell
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 跳轉會員訂單明細頁面
        currIndexPath = indexPath
        self.performSegueWithIdentifier("SaleDetail", sender: aryPurchaseData[indexPath.row])
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        //  會員訂單明細頁面
        if (strIdentName == "SaleDetail") {
            let mVC = segue.destinationViewController as! SaleDetail
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            mVC.delegate = self
            
            return
        }
        
        return
    }
    
}