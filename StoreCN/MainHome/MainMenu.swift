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

    // common property
    //var mVCtrl: UIViewController!
    let pubClass = PubClass()
    let mJSONClass = JSONClass()
    let mFileMang = FileMang()
    
    // parent Segue 設定
    var aryMember: Array<Dictionary<String, String>> = []
    var aryPict: Dictionary<String, String> = [:]
    
    // 產生 UIAlertController (popWindow 資料傳送中)
    var vcPopLoading: UIAlertController!
    
    // 其他參數設定
    var strToday = ""
    var strTodayMsg = ""
    private var currMenuIndexPath: NSIndexPath?
    
    // HTTP 連線參數設定
    private var dictParm: Dictionary<String, String> = [:]
    
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
        
        // HTTP 連線參數設定
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
    }
    
    /**
     * View Disappear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        currMenuIndexPath = nil
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        self.pubClass.ReloadAppDelg()
        colviewMenu.reloadData()
        
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
        var mParam = dictParm
        mParam["page"] = "homepage"
        mParam["act"] = "homepage_remindall"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: HttpResponChk)
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
        if let aryData = dictData["course"] as? Array<Dictionary<String, AnyObject>> {
            aryExpire = aryData
        }
        
        // 庫存不足商品
        var aryStock: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["stock"] as? Array<Dictionary<String, AnyObject>> {
            aryStock = aryData
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
        mCell.layer.borderWidth = 2
        mCell.layer.cornerRadius = 5
        
        if (indexPath == currMenuIndexPath) {
            mCell.layer.borderColor = pubClass.ColorHEX(pubClass.dictColor["red"]).CGColor
        } else {
            mCell.layer.borderColor = pubClass.ColorHEX(pubClass.dictColor["white"]).CGColor
        }
        
        return mCell
    }
    
    /**
     * #mark: CollectionView, Cell click
     * 點取主選單項目
     */
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        currMenuIndexPath = indexPath
        colviewMenu.reloadData()
        
        let position = indexPath.row
        let strItem = aryMenuName[position]

        // 直接跳轉 VC
        if (strItem == "member" || strItem == "testing") {
            var strIdentName = ""
            if (strItem == "member") {
                strIdentName = "member_list"
            }
            
            self.performSegueWithIdentifier(strIdentName, sender: nil)
            return
        }
        
        // 彈出 ActionSheet 子選單
        var mAlert = UIAlertController(title: pubClass.getLang("menu_" + strItem), message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)

        switch (strItem) {
            // 服務管理
        case "servicemgr":
            mAlert = resetAlertVC(mAlert, withAryIdent: ["course_list", "course_reservation", "course_sale"])
            break
            
            // 商品管理
        case "product":
            mAlert = resetAlertVC(mAlert, withAryIdent: ["product_sale", "product_purchase", "product_stock", "product_purchaselist"])
            break
            
            // 人力管理
        case "staff":
            mAlert = resetAlertVC(mAlert, withAryIdent: ["staff_employee", "staff_benefit"])
            break

        default:
            break
        }
        
        mAlert.addAction(UIAlertAction(title: pubClass.getLang("cancel"), style: UIAlertActionStyle.Destructive, handler:nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(mAlert, animated: true, completion: nil)
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
                
                /* 判斷是否需要 'prepareForSegue' */
                var mParam = self.dictParm
                
                // 療程列表
                if (strIdent == "course_list") {
                    mParam["page"] = "cardmanage"
                    mParam["act"] = "cardmanage_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 療程預約
                if (strIdent == "course_reservation") {                    
                    mParam["page"] = "course"
                    mParam["act"] = "course_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 療程銷售
                if (strIdent == "course_sale") {
                    mParam["page"] = "coursesale"
                    mParam["act"] = "coursesale_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 商品入庫
                if (strIdent == "product_purchase") {
                    mParam["page"] = "purchase"
                    mParam["act"] = "purchase_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 商品銷售
                if (strIdent == "product_sale") {
                    mParam["page"] = "sale"
                    mParam["act"] = "sale_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 商品庫存
                if (strIdent == "product_stock") {
                    mParam["page"] = "stock"
                    mParam["act"] = "stock_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 商品進貨列表, HTTP 連線取得資料直接由 child 'PurchaseList' 處理
                if (strIdent == "product_purchaselist") {
                    self.performSegueWithIdentifier(strIdent, sender: nil)
                    return
                }
                
                // 營養師列表, HTTP 連線取得資料直接由 child 'PurchaseList' 處理
                if (strIdent == "staff_employee") {
                    self.performSegueWithIdentifier("StaffList", sender: nil)
                    return
                }
                
                // 營養師列表, HTTP 連線取得資料直接由 child 'PurchaseList' 處理
                if (strIdent == "staff_benefit") {
                    self.performSegueWithIdentifier("StaffBenefit", sender: nil)
                    return
                }
            }))
        }
        
        return mAlert
    }
    
    /**
    * 主選單項目點取時，執行http連線取的資料，再傳入指定的VC
    */
    private func MenuItemSelect(strIdent: String!, HTTPParam mParam: Dictionary<String, String>!) {
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤顯示錯誤訊息
            if (dictRS["result"] as! Bool != true) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: self.pubClass.getLang(dictRS["msg"] as? String))
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            if let today = dictData["today"] as? String {
                if (today.characters.count == 14) {
                    self.strToday = today
                }
            }
            
            // 將整個回傳資料傳送下個頁面
            self.performSegueWithIdentifier(strIdent, sender: dictData)
        })
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 療程列表
        if (strIdent == "course_list") {
            let mVC = segue.destinationViewController as! Courselist
            mVC.strToday = strToday
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>

            return
        }
        
        // 療程預約
        if (strIdent == "course_reservation") {
            let mVC = segue.destinationViewController as! CourseReserv
            mVC.strToday = strToday
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
        // 療程銷售
        if (strIdent == "course_sale") {
            let mVC = segue.destinationViewController as! CourseSale
            mVC.strToday = strToday
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
        // 商品入庫
        if (strIdent == "product_purchase") {
            let mVC = segue.destinationViewController as! Purchase
            mVC.strToday = strToday
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
        // 商品銷售
        if (strIdent == "product_sale") {
            let mVC = segue.destinationViewController as! Sale
            mVC.strToday = strToday
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
        // 商品庫存
        if (strIdent == "product_stock") {
            let mVC = segue.destinationViewController as! Stock
            mVC.strToday = strToday
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
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
        initViewField()
    }
    

}

