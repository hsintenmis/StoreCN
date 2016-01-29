//
// CollectionView, delegate 直接由 storyboard 設定
//

import UIKit
import Foundation

/**
 * 主選單
 */
class MainMenu: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var labTodayMsg: UILabel!
    @IBOutlet weak var colviewMenu: UICollectionView!

    // public property
    var mVCtrl: UIViewController!
    let pubClass = PubClass()
    let mJSONClass = JSONClass()
    let mFileMang = FileMang()
    
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // parent Segue 設定
    var aryMember: Array<Dictionary<String, String>> = []
    var aryPict: Dictionary<String, String> = [:]
    
    // 產生 UIAlertController (popWindow 資料傳送中)
    var vcPopLoading: UIAlertController!
    
    // 其他參數設定
    var strToday = ""
    var strTodayMsg = ""
    
    // 顏色
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0", "blue":"66CCFF", "black":"000000", "green":"99CC33"]
    
    // 選單相關設定
    /** 選單代碼："member", "testing", "servicemgr", "product", "staff", "message", "storesheet", "config" */
    private let aryMenuName = ["member", "testing", "servicemgr", "product", "staff", "message", "storesheet", "config"]
    
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
    override func viewWillAppear(animated: Bool) {

    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        self.pubClass.ReloadAppDelg()
        dictPref = pubClass.getPrefData()
        
        dispatch_async(dispatch_get_main_queue(), {
            // 連線取得資料
            self.StartHTTPConn()
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        labTodayMsg.text = strTodayMsg
        
        // 設定 CollectionView, 選單資料
        
    }
    
    /**
     * 登入後主選單，連線取得資料
     */
    private func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "homepage";
        dictParm["act"] = "homepage_remindall";
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVCtrl, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        /* 解析正確的 http 回傳結果，執行後續動作 */
        let dictData = (dictRS["data"]!["content"]!)!
        
        // 今天日期
        strToday = dictData["today"] as! String
        
        // 今日預約療程資料
        var aryTodayCourse: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["reser"] as? Array<Dictionary<String, AnyObject>> {
            aryTodayCourse = aryData
        }
        
        // 療程快到期資料
        var aryExpire: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["course"] {
            aryExpire = aryData as! Array<Dictionary<String, AnyObject>>
        }
        
        // 庫存不足商品
        var aryStock: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["stock"] {
            aryStock = aryData as! Array<Dictionary<String, AnyObject>>
        }
        
        // 產生'今日提醒文字'
        strTodayMsg = String(format: pubClass.getLang("FMT_todayinfo"), arguments: [aryTodayCourse.count, aryExpire.count, aryStock.count])
        
        // 頁面 field 資料初始與設定
        initViewField()
    }
    
    /**
     * #mark: CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #mark: CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryMenuName.count
    }
    
    /**
     * #mark: CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell: MainMenuColtViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellMainMenuColtView", forIndexPath: indexPath) as! MainMenuColtViewCell
        
        let position = indexPath.row
        mCell.labTitle.text = pubClass.getLang("menu_" + aryMenuName[position])
        mCell.imgPict.image = UIImage(named: "menu_" + aryMenuName[position])
        
        // 樣式/外觀/顏色
        /*
        mCell.layer.cornerRadius = 5
        mCell.layer.borderWidth = 1
        mCell.layer.borderColor = pubClass.ColorHEX(dictColor["gray"]).CGColor
        */
        
        //var strColor = "gray"
        //mCell.backgroundColor = pubClass.ColorHEX(dictColor[strColor])
        
        return mCell
    }
    
    /**
     * #mark: CollectionView, Cell click
     * 點取主選單項目
     */
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {

        let position = indexPath.row
        let strItem = aryMenuName[position]

        // 直接跳轉 VC
        if (strItem == "member" || strItem == "testing") {
            self.performSegueWithIdentifier(strItem, sender: nil)
            return
        }
        
        // 彈出 ActionSheet 子選單
        var mAlert = UIAlertController(title: pubClass.getLang("menu_" + strItem), message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)

        switch (strItem) {
            // 服務管理
        case "servicemgr":
            mAlert = resetAlertVC(mAlert, withAryIdent: ["course_list", "course_reservation", "course_sale"])
            break
        default:
            break
        }
        
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("cancel"), style: UIAlertActionStyle.Destructive, handler:nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
    * ActionSheet, 子選單點取, 重設定 'mAlert' 相關內容
    * 跳轉至指定的名稱的Segue頁面
    */
    private func resetAlertVC(mAlert: UIAlertController, withAryIdent aryIdent: Array<String>!) -> UIAlertController {
        
        // loop 子選單 ident name, 重新產生 UIAlertController
        for strIdent in aryIdent {
            mAlert.addAction(UIAlertAction(title:pubClass.getLang("menu_" + strIdent), style: UIAlertActionStyle.Default, handler:{
                (alert: UIAlertAction!)->Void in
                    self.performSegueWithIdentifier(strIdent, sender: nil)
            }))
        }
        
        return mAlert
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        //print(strIdent)
        
        return
    }
    
    /**
     * act, 點取 '登出' button
     */
    @IBAction func actLogout(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    /**
     * act, 點取 '刷新' button
     */
    @IBAction func actReload(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue(), {
            // 連線取得資料
            self.StartHTTPConn()
        })
        
        self.pubClass.ReloadAppDelg()
        dictPref = pubClass.getPrefData()
        initViewField()
    }
    

}

