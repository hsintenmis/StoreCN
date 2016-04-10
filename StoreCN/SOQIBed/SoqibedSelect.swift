//
// UITableView, 上層為 Container
//

import UIKit
import Foundation

/**
 * 指定會員的 SOQIBed 列表, 來源: 1.購買療程附加 2.MEAD檢測附加
 * 本 class 由 'MemberMainPager' 實體化產生
 */
class SoqibedSelect: UITableViewController, PubClassDelegate {
    // delegate, 會員主頁面資料變動
    var delegate = MemberHttpDataDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, paent 設定, Table DataSource, Soqibed 全部的檢測資料
    var arySoqibedData: Array<Dictionary<String, AnyObject>> = []
    var strMemberId: String!  // 指定會員ID
    var strToday = ""
    
    // 其他參數設定
    private var mMemberHttpData: MemberHttpData!  // http 連線取得會員全部資料
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mMemberHttpData = MemberHttpData(VC: self)
        labNoData.alpha = 0.0
        
        if (self.arySoqibedData.count < 1) {
            self.labNoData.alpha = 1.0
        }
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
            
            if let aryTmp = dictAllMemberData["soqibed"] as? Array<Dictionary<String, AnyObject>> {
                self.arySoqibedData = aryTmp
                self.labNoData.alpha = 0.0
            } else {
                self.arySoqibedData = []
                self.labNoData.alpha = 1.0
                self.currIndexPath = nil
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
        return arySoqibedData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, Cell 使用 Table Cell 預設的樣式
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (arySoqibedData.count < 1) {
            return UITableViewCell()
        }
        
        // 取得 Item data source, CellView
        let ditItem = arySoqibedData[indexPath.row]
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPubSoqibedSelect")!
        
        // 使用時間 array data
        var strCounts = "0"
        if let aryTimes = ditItem["times"] as? Array<Dictionary<String, String>> {
            strCounts = String(aryTimes.count)
        }
        
        let strSDate = pubClass.formatDateWithStr(ditItem["sdate"] as? String, type: "8s")
        let strSubTitle = pubClass.getLang("soqibed_actdate") + ": " + strSDate + ", " + pubClass.getLang("soqibed_usecount") + ": " + strCounts
        
        mCell.textLabel?.text = ditItem["title"] as? String
        mCell.detailTextLabel?.text = strSubTitle
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // 取得選擇的 SOQIBED dict Data, 跳轉編輯頁面
        currIndexPath = indexPath
        self.performSegueWithIdentifier("SoqibedEdit", sender: arySoqibedData[indexPath.row])
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        //  SOQIBED 編輯頁面
        if (strIdentName == "SoqibedEdit") {
            let mVC = segue.destinationViewController as! SoqibedEdit
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            mVC.delegate = self
            
            return
        }
        
        return
    }
    
}