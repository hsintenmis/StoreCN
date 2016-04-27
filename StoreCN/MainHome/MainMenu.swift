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
    @IBOutlet weak var btnRemind: UIButton!
    @IBOutlet weak var labMsg: UILabel!
    @IBOutlet weak var labActTitle: UILabel!
    @IBOutlet weak var labActMsg: UILabel!
    @IBOutlet weak var btnActInfo: UIButton!
    
    // common property
    private let pubClass = PubClass()
    private let mJSONClass = JSONClass()
    private let mFileMang = FileMang()

    // 選單相關設定
    private let aryMenuName = ["member", "testing", "servicemgr", "product", "staff", "message", "analydata", "config"]
    
    // 其他參數
    private var dictParm: Dictionary<String, String> = [:] // HTTP 連線參數設定
    private var bolReload = true  // 本頁面是否重整
    private var strToday = ""
    private var strTodayMsg = ""
    private var currMenuIndexPath: NSIndexPath?
    private var dictRemind: Dictionary<String, AnyObject> = [:]  // 今日提醒全部資料
    private var dictActInfo: Dictionary<String, AnyObject> = [:]  // 店家活動專區資料
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnActInfo.layer.cornerRadius = 5.0
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
        if (bolReload == true) {
            bolReload = false
            colviewMenu.reloadData()
            self.StartHTTPConn()
        }
    }
    
    /**
     * 登入後主選單，連線取得資料
     */
    private func StartHTTPConn() {
        // HTTP 連線參數設定
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        
        // 連線 HTTP post/get 參數
        var mParam = dictParm
        mParam["page"] = "homepage"
        mParam["act"] = "homepage_remindall"
        
        // HTTP 開始連線
        btnRemind.enabled = false
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
        labTodayMsg.text = strTodayMsg
        
        // 產生今日提醒全部資料的 dict array data
        dictRemind["reser"] = aryTodayCourse
        dictRemind["course"] = aryExpire
        dictRemind["stock"] = aryStock
        btnRemind.enabled = true
        
        // 目前登入者名稱
        labMsg.text = String(format: pubClass.getLang("FMT_currentloginname"), dictRS["data"]!["name"] as! String)
        
        // 2016/04/27, 新增店家活動專區
        dictActInfo = dictData["actinfo"] as! Dictionary<String, String>
        labActTitle.text = dictActInfo["title"] as? String
        labActMsg.text = dictActInfo["msg"] as? String
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
        
        /* 直接跳轉 storyborad */
        if (strItem == "testing") {
            let storyboardProduct = UIStoryboard(name: "Testing", bundle: nil)
            let controller = storyboardProduct.instantiateViewControllerWithIdentifier("TestingDevLiist") as UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
            
            return
        }
        
        if (strItem == "config") {
            let storyboardProduct = UIStoryboard(name: "SysConfig", bundle: nil)
            let controller = storyboardProduct.instantiateViewControllerWithIdentifier("SysConfigMain") as UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
            
            return
        }

        // 會員列表
        if (strItem == "member") {
            self.performSegueWithIdentifier("MemberList", sender: nil)
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
            
            // 訊息管理
        case "message":
            mAlert = resetAlertVC(mAlert, withAryIdent: ["message_active", "message_health"])
            break
            
            // 店務資料分析
        case "analydata":
            mAlert = resetAlertVC(mAlert, withAryIdent: ["analydata_income", "analydata_health"])
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
                
                /* 直接跳轉 storyborad */
                var mVC: UIViewController?
                
                // 療程列表
                if (strIdent == "course_list") {
                    let storyboard = UIStoryboard(name: "CourseMain", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("CourseListAll") as UIViewController
                }
                    
                // 療程預約
                else if (strIdent == "course_reservation") {
                    let storyboard = UIStoryboard(name: "CourseMain", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("CourseReserv") as UIViewController
                }
                
                // 商品進出貨列表
                else if (strIdent == "product_purchaselist") {
                    let storyboard = UIStoryboard(name: "Product", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("PurchaseList") as UIViewController
                }
                
                // 分析報表 - 損益
                else if (strIdent == "analydata_income") {
                    let storyboard = UIStoryboard(name: "AnalyData", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("AnalyDataMain") as UIViewController
                }
                
                // 分析報表 - 健康精靈會員
                else if (strIdent == "analydata_health") {
                    let storyboard = UIStoryboard(name: "AnalyData", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("AnalyDataHealth") as UIViewController
                }
                
                // 員工列表
                else if (strIdent == "staff_employee") {
                    let storyboard = UIStoryboard(name: "Staff", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("StaffList") as UIViewController
                }
                
                // 員工績效
                else if (strIdent == "staff_benefit") {
                    let storyboard = UIStoryboard(name: "Staff", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("StaffBenefit") as UIViewController
                }
                
                // 訊息 - 列表與發布
                else if (strIdent == "message_active") {
                    let storyboard = UIStoryboard(name: "Message", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("MsgList") as UIViewController
                }
                    
                // 訊息 - 健康資訊網頁
                else if (strIdent == "message_health") {
                    let storyboard = UIStoryboard(name: "Message", bundle: nil)
                    mVC = storyboard.instantiateViewControllerWithIdentifier("HealthWitnessList") as UIViewController
                }
                
                if (mVC != nil) {
                    self.presentViewController(mVC!, animated: true, completion: nil)
                    return
                }
                
                /* 判斷是否需要 'prepareForSegue', 資料先由本 class http 連線取得 */
                var mParam = self.dictParm
                
                // 療程銷售
                if (strIdent == "course_sale") {
                    mParam["page"] = "coursesale"
                    mParam["act"] = "coursesale_getdata"
                    self.MenuItemSelect(strIdent, HTTPParam: mParam)
                    
                    return
                }
                
                // 商品入庫
                if (strIdent == "product_purchase") {
                    
                    // 商品進貨，身份為員工
                    if ((self.pubClass.getAppDelgVal("V_USRROLE") as! Int) < 9) {
                        self.pubClass.popIsee(self, Msg: self.pubClass.getLang("fundonotallowuse"))
                        return
                    }
                    
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
                
                /*
                // 直接 performSegueWithIdentifier 跳轉，設定對應 ident
                let dictIdentMap = [
                    "course_reservation":"CourseReserv",
                ]
                
                // HTTP 連線取得資料直接由 child 執行　http 連線取得資料
                self.performSegueWithIdentifier(dictIdentMap[strIdent]!, sender: nil)
                return
                */
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
            
            /* 跳轉其他 storyboard */
            // 療程銷售
            if (strIdent == "course_sale") {
                let storyboard = UIStoryboard(name: "CourseMain", bundle: nil)
                let mVC = storyboard.instantiateViewControllerWithIdentifier("CourseSale") as! CourseSale
                mVC.strToday = self.strToday
                mVC.dictAllData = dictData
                self.presentViewController(mVC, animated: true, completion: nil)
                
                return
            }
            
            /* 直接跳轉商品 storyborad */
            let storyboardProduct = UIStoryboard(name: "Product", bundle: nil)
                
            // 商品入庫
            if (strIdent == "product_purchase") {
                let mVC = storyboardProduct.instantiateViewControllerWithIdentifier("Purchase") as! Purchase
                mVC.strToday = self.strToday
                mVC.dictAllData = dictData
                self.presentViewController(mVC, animated: true, completion: nil)
                
                return
            }
            
            // 商品銷售
            if (strIdent == "product_sale") {
                let mVC = storyboardProduct.instantiateViewControllerWithIdentifier("PdSale") as! Sale
                mVC.strToday = self.strToday
                mVC.dictAllData = dictData
                self.presentViewController(mVC, animated: true, completion: nil)
                
                return
            }
             
            // 商品庫存
            if (strIdent == "product_stock") {
                let mVC = storyboardProduct.instantiateViewControllerWithIdentifier("PdStock") as! Stock
                mVC.strToday = self.strToday
                mVC.dictAllData = dictData
                self.presentViewController(mVC, animated: true, completion: nil)
                
                return
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
        
        // 今日提醒列表
        if (strIdent == "RemindList") {
            let mVC = segue.destinationViewController as! RemindList
            mVC.dictAllData = self.dictRemind
            mVC.strToday = strToday
            return
        }
        
        // 店家活動專區
        if (strIdent == "ActInfo") {
            let mVC = segue.destinationViewController as! ActInfo
            mVC.dictAllData = self.dictActInfo
            mVC.strToday = strToday
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '今日提醒' button
     */
    @IBAction func actRemind(sender: UIButton) {
        print("actRemind")
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
        self.StartHTTPConn()
    }
    
}