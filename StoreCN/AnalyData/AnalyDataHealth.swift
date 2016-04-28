//
// TableView
//

import UIKit
import Foundation

/**
 * 健康精靈使用狀況分析
 */
class AnalyDataHealth: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    @IBOutlet weak var lab_nums_member: UILabel!
    @IBOutlet weak var lab_nums_login: UILabel!
    @IBOutlet weak var lab_nums_testing: UILabel!
    @IBOutlet weak var lab_nums_nologin: UILabel!
    
    // common property
    private var pubClass: PubClass!
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // table data 設定, 兩個 table array data
    private var dictTableData: Dictionary<String, Array<Dictionary<String, AnyObject>>> = [:]
    
    // 其他參數設定
    private let aryField = ["testing", "login"]  // 兩個 table datasource field name
    private var currPosition = 0
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // 初始 table data
        for strField in aryField {
            dictTableData[strField] = []
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            reConnHTTP()
            bolReload = false
        }
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 檢查是否有資料, 無資料跳離
        for strField in aryField {
            if let aryTmp = dictAllData[strField] as? Array<Dictionary<String, AnyObject>> {
                dictTableData[strField] = aryTmp
            } else {
                pubClass.popIsee(self, Msg: pubClass.getLang("err_data"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
                return
            }
        }
        
        // 設定 field value
        lab_nums_member.text = dictAllData["nums_member"] as? String
        lab_nums_login.text = dictAllData["nums_login"] as? String
        lab_nums_testing.text = dictAllData["nums_testing"] as? String
        lab_nums_nologin.text = dictAllData["nums_nologin"] as? String
        
        // tableview reload
        tableData.reloadData()
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "analydata"
        mParam["act"] = "analydata_health"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                
                // 取得回傳錯誤訊息
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                if let strTmp = dictRS["data"]?["msg"] as? String {
                    if (strTmp.characters.count > 0) {
                        errMsg = strTmp
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            self.dictAllData = dictData
            self.chkHaveData()
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
        return dictTableData[aryField[currPosition]]!.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (dictTableData[aryField[currPosition]]!.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = dictTableData[aryField[currPosition]]![indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellAnalyDataHealth", forIndexPath: indexPath) as! AnalyDataHealthCell
        
        mCell.initView(ditItem, PubClass: pubClass, tabelFlag: aryField[currPosition])
        
        return mCell
    }
    
    /**
     * act, 點取 Segment 切換 table data
     */
    @IBAction func actChangTable(sender: UISegmentedControl) {
        currPosition = sender.selectedSegmentIndex
        tableData.reloadData()
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}