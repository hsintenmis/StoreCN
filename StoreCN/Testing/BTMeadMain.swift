//
// UIViewController, UICollectionView
//

import UIKit
import Foundation

/**
 * 能量檢測儀 主頁面
 * 1.藍芽設備連接    2.會員選擇(USER資料輸入)
 * 3.測量完後檢測報告 4. 儲存
 */
class BTMeadMain: UIViewController, TestingMemberSelDelegate, BTMeadServiceDelegate {
    // @IBOutlet
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var imgBody: UIImageView!
    @IBOutlet weak var viewCollect: UICollectionView!
    @IBOutlet weak var labBTMsg: UILabel!
    @IBOutlet weak var labPointMsg: UILabel!
    @IBOutlet weak var labPointMsg1: UILabel!
    @IBOutlet weak var labTestVal: UILabel!
    @IBOutlet weak var labTxtExistVal: UILabel!
    @IBOutlet weak var labExistVal: UILabel!
    
    @IBOutlet weak var btnMember: UIButton!
    @IBOutlet weak var btnReset: UIBarButtonItem!
    @IBOutlet weak var btnReport: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var imgLoading: UIActivityIndicatorView!
    @IBOutlet weak var btnConn: UIButton!
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 本頁面檢測的狀態參數設定
    private let STATU_READY = 3001;   // 等待接收資料中, 檢測值=1
    private let STATU_RECEIVE = 3002; // 資料接收中, 檢測值需判斷區間, 參考MeadCFG
    private let STATU_FINISH = 3003;  // 單一檢測項目完成, 已達取樣 maxCount
    private let STATU_STOP = 3004;    // 停止接收數值分析
    
    private var CURR_STATU = 3004     // 目前檢測的狀態, 預設為 '檢測結束'
    
    // MEAD 數值取樣設定
    private let D_MAXCOUNT = 200 // 接收到的檢測數值, 計算加總的最大次數
    private var currValCount = 0  // 目前檢測數值計算加總的次數
    private var mapTestValCount: Dictionary<String, Int> = [:] // 檢測數值 => 出現次數, 目的取得最多次數的 val
    
    /** 
     * 檢測數值 array data, 從 'MeadCFG' class 初始取得<P>
     * 資料設定如下<br>
     * id :辨識 id, ex. H1, H2 ...<br>
     * body : 身體部位, ex. 'H' or 'F'<BR>
     * direction : 左右, ex. L or R ...<br>
     * val : 檢測值, 預設 0, String 型態<br>
     * serial : 身體與方向對應序號, 1 ~ 6<br>
     */
    var aryTestingData: Array<Dictionary<String, String>> = []
    
    // 目前檢測資料的 position, 與 CollectionView 的 position 一樣
    var currDataPosition = 0;
    var currIndexPath = NSIndexPath(forRow: 0, inSection:0)
    
    // 其他參數
    private var mBTMeadService: BTMeadService!  // 檢測儀藍牙 Service
    private var mMeadCFG = MeadCFG() // MEAD, 設定檔
    private var mMeadClass = MeadClass() // MEAD class
    
    private var dictMember: Dictionary<String, AnyObject> = [:]  // 選擇的會員資料
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var isDataSave = false  // 檢測資料是否已存檔
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BTScaleService 實體化與相關參數設定
        mBTMeadService = BTMeadService()
        mBTMeadService.delegate = self

        // view field value 設定
        labBTMsg.text = pubClass.getLang("bt_searching")
        btnConn.alpha = 0.0
        setBtnActive(false)
        
        // 檢測數值 array data 初始與產生
        aryTestingData = mMeadCFG.getAryAllTestData()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        mBTMeadService.BTConnStart()
    }
    
    /**
    * Button 點取無作用，藍牙狀態為 '已連線' 才設定 enable
    */
    private func setBtnActive(isEnable: Bool) {
        btnMember.enabled = isEnable
        btnReset.enabled = isEnable
        btnReport.enabled = isEnable
        btnSave.enabled = isEnable
        
        btnConn.enabled = !isEnable
        
        if (isEnable == true) {
            imgLoading.stopAnimating()
            imgBody.alpha = 1.0
            btnConn.alpha = 0.0
        } else {
            imgBody.alpha = 0.0
        }
    }
    
    /**
     * #mark: TestingMemberSel Delegate
     * 點取會員後執行相關程序
     */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        currIndexMember = MemberindexPath
        
        // 重新設定儲存狀態
        if (dictMember["membeid"] != nil) {
            if (MemberData["membeid"] as? String != dictMember["membeid"] as? String) {
                self.isDataSave = false
            }
        }
        
        dictMember = MemberData
        
        // 會員名稱與相關資料重新顯示
        let strGender = pubClass.getLang("gender_" + (dictMember["gender"] as? String)!)
        let strAge = (dictMember["age"] as! String)  + pubClass.getLang("name_age")
        let strHeight = (dictMember["height"] as! String) + "cm"
        let strMemberInfo = strGender + strAge + ", " + strHeight
        
        labGender.text = strMemberInfo
        labName.text = dictMember["membername"] as? String
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定列數 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定每列 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    /**
     * #mark, CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBTMeadMain", forIndexPath: indexPath) as! BTMeadMainCell
        
        let dictItem = aryTestingData[indexPath.row]
        mCell.initView(dictItem, mPubClass: pubClass, indexpath: indexPath, selectedIndex: currIndexPath)
        
        return mCell
    }
    
    /**
     * #mark, CollectionView, Cell 點取, 檢測項目的 scroll item
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if (mBTMeadService.BT_ISREADYFOTESTING) {
            currIndexPath = indexPath
            
            // 重新改變狀態
            CURR_STATU = STATU_FINISH
            self.moveCollectCell(indexPath.row)
        }
    }

    /**
     * CollectionView 移動到指定的 position cell
     * 本頁面 IBOutlet 跟著變動
     */
    private func moveCollectCell(mRow: Int) {
        let dictItem = aryTestingData[mRow]
        currDataPosition = mRow
        currIndexPath = NSIndexPath(forRow: mRow, inSection:0)
        
        // 設定穴位圖片, 圖片路徑 'pict_testing', 圖片名稱 ex. F1_R_P.jpg
        let strPict = dictItem["id"]! + "_" + dictItem["direction"]! + "_P.jpg"
        imgBody.image = UIImage(named: "pict_testing/" + strPict)
        
        // CollectionView 更新
        viewCollect.scrollToItemAtIndexPath(currIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        viewCollect.reloadData()
        
        // 其他 IBOutlet 更新
        labPointMsg.text = pubClass.getLang("MERIDIAN_" + dictItem["id"]!)
        labPointMsg1.text = pubClass.getLang("ORAGN_" + dictItem["id"]!)
        labExistVal.text = dictItem["val"]
        
        // 重新改變狀態
        CURR_STATU = STATU_FINISH
    }
    
    /**
     * #mark: BTMeadServiceDelegate
     * 檢測儀 Service class, handler
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, intVal: Int?) {
        switch (identCode) {
        case "BT_conn":
            if (result != true) {
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                // BT 設備連線成功
                self.moveCollectCell(0)
                CURR_STATU = STATU_READY
            }
            
            setBtnActive(result)
            labBTMsg.text = msg
            
            break
            
        case "BT_statu":
            if (result != true) {
                mBTMeadService.BTDisconn()
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                return
            }
            
            labBTMsg.text = msg
            
            // 搜尋不到藍芽設備，int 代碼 1, 手機藍牙未開 = 3
            if let code = intVal {
                if (code == 1 || code == 3) {
                    imgLoading.stopAnimating()
                    btnConn.alpha = 1.0
                    
                    break
                }
                
                // 不能使用藍芽設備，跳離
                if (code == 2) {
                    pubClass.popIsee(self, Msg: msg, withHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    return
                }
            }
            
            break
            
        // 藍芽設備回傳資料
        case "BT_data":
            // 有回傳資料 Int val NOT nil
            if (result == true ) {
                if (intVal! < mMeadCFG.D_VALUE_MAX) {
                    analyMEADVal(intVal!)
                }
            }
            
            break
            
        default:
            break
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員選擇(公用)
        if (strIdent == "TestingMemberSel") {
            let mVC = segue.destinationViewController as! TestingMemberSel
            mVC.strToday = self.strToday
            mVC.aryMember = self.aryMember
            mVC.currIndexPath = self.currIndexMember
            mVC.delegate = self
            
            return
        }
        
        // MEAD 檢測報告頁面
        if (strIdent == "RecordDetail") {
            let mVC = segue.destinationViewController as! RecordDetail
            mVC.dictMeadData = sender as! Dictionary<String, String>
            
            return
        }
        
        return
    }
    
    /**
     * 解析檢測儀傳來的數值資料
     * <P>
     * 檢測狀態: <BR>
     * STATU_READY: 檢測值 = 1, 探針未與任何量測點接觸<BR>
     * STATU_RECEIVE: 檢測值 > 1, 量測點正在確認中<BR>
     * STATU_FINISH: 到達 maxCount, 完成數值讀取，移到下一個/檢測完成(Item position = 最後一個)<BR>
     *
     * @param intVal
     *            : 檢測值
     */
    private func analyMEADVal(intVal: Int!) {
        if (CURR_STATU == STATU_STOP) {
            return
        }
        
        let strVal = String(intVal)
        
        // STATU_READY, 檢測值 = 1, 探針未與任何量測點接觸
        if (intVal == 1) {
            
            // 設定目前檢測狀態，顯示提示訊息
            if ( CURR_STATU != STATU_READY ) {
                CURR_STATU = STATU_READY
                mapTestValCount = [:] // 重設 val 對應次數 dict data
                labBTMsg.text = pubClass.getLang("mead_point_ready")
                labTestVal.text = "0"
            }
            
            // 數值計算 maxCount = 0
            currValCount = 0
            
            return
        }
        
        // STATU_RECEIVE, 檢測值 > 1, 預設狀態為：量測點正在確認中
        
        // 目前狀態 = STATU_FINISH, 無動作
        if (CURR_STATU == STATU_FINISH) {
            return
        }
        
        // 設定目前檢測狀態，顯示提示訊息
        if (CURR_STATU != STATU_RECEIVE) {
            CURR_STATU = STATU_RECEIVE
            labBTMsg.text = pubClass.getLang("mead_point_recive")
        }
        
        // 螢幕顯示檢測數值
        self.labTestVal.text = String(strVal)
        
        // 數值資料加入 '取樣設定' dict array
        if ( currValCount <= D_MAXCOUNT ) {
            if let count: Int = mapTestValCount[strVal] {
                mapTestValCount[strVal] = count + 1
            } else {
                mapTestValCount[strVal] = 1
            }
            
            currValCount += 1
            
            return
        }
        
        // 取樣程序, 已經達到最大的計算次數，該檢測項目檢測完成
        currValCount = 0
        
        // 取得出現次數最多的值，將數值資料設定到 'aryTestingData'
        var strMaxCountVal = "0" // 次數最多的檢測值
        var currCount = 0  // 暫存比較用的 count
        
        // key/value loop 資料, 找出現次數最多的數值 'strMaxCountVal'
        for (tmpVal, tmpCount) in mapTestValCount {
            if (tmpCount > currCount) {
                strMaxCountVal = tmpVal
                currCount = tmpCount
            }
        }
        
        // 將出現次數最多的數值 加入 'aryTestingData'
        aryTestingData[currDataPosition]["val"] = strMaxCountVal
        labExistVal.text = strMaxCountVal
        
        // 是否已到最後一筆 檢測項目, 所有項目檢測完成，執行相關程序
        if ( currDataPosition == (mMeadCFG.D_TOTDATANUMS - 1) ) {
            CURR_STATU = STATU_STOP
            labBTMsg.text = pubClass.getLang("mead_point_finish")
            
            return
        }
        
        // 設定目前狀態為 'STATU_FINISH'
        CURR_STATU = STATU_FINISH;
        labBTMsg.text = pubClass.getLang("mead_point_movenext")
        
        // 目前檢測項目 position + 1, collectionView position 移動
        currDataPosition += 1
        moveCollectCell(currDataPosition)
        
        return
    }
    
    /**
     * 檢查 MEAD 各個項目的數值資料(array string val)
     * '資料存檔'與'檢測報告'使用
     *
     * @param showPopMsg: 是否顯示彈出視窗
     * @return boolean
     */
    private func chkTestingData(showPopMsg isShow: Bool)->Bool {
        for i in (0..<24) {
            var dictItem = aryTestingData[i]
            
            if (dictItem["val"] == "0") {
                // 數值資料 "0" 為錯誤
                self.moveCollectCell(i)
                
                if (isShow) {
                    self.pubClass.popIsee(self, Msg: self.pubClass.getLang("mead_errval"))
                }
                
                return false
            }
        }
        
        return true
    }
    
    /**
     * 將已檢測完的數值資料，整理成為 存檔用的 Dict data
     *   格式如下：
     *  'sdate': 14碼, 作為唯一識別 key
     *  'memberid': ex. MD000001
     *  'membername': 會員姓名
     *  'age': ex. "35"
     *  'gender': ex. "M"
     *  'avg', 'avgH', 'avgL'
     *  'val': ex. "27,12,33,56,34,67,..."
     *  'problem': 超出高低標的檢測項目, ex. "F220,H101,H420,..." or ""
     */
    private func getPreSaveData(aryData: Array<Dictionary<String, String>>)->Dictionary<String, String>! {
        var dictRS: Dictionary<String, String> = [:]
        
        dictRS["sdate"] = strToday
        dictRS["memberid"] = dictMember["memberid"] as? String
        dictRS["membername"] = dictMember["membername"] as? String
        dictRS["age"] = dictMember["age"] as? String
        dictRS["gender"] = dictMember["gender"] as? String
        
        // 已檢測的數值
        dictRS["val"] = ""
        for i in (0..<mMeadCFG.D_TOTDATANUMS) {
            dictRS["val"] = dictRS["val"]! + aryData[i]["val"]!
            if (i < (mMeadCFG.D_TOTDATANUMS - 1)) { dictRS["val"]! += "," }
        }
        
        // 平均值, 高低標
        let dictAvg = mMeadClass.GetAvgValue(aryTestingData)
        dictRS["avg"] = String(dictAvg["avg"]!)
        dictRS["avgH"] = String(dictAvg["avgH"]!)
        dictRS["avgL"] = String(dictAvg["avgL"]!)
        
        // 有問題的檢測項目
        dictRS["problem"] = mMeadClass.GetProblemItem(aryTestingData)
        
        return dictRS
    }

    /**
     * act, 點取 '重新連線'
     */
    @IBAction func actConn(sender: UIButton) {
        imgLoading.startAnimating()
        btnConn.alpha = 0.0
        mBTMeadService.BTConnStart()
    }
    
    /**
     * act, UIBarButtonItem, 顯示檢測報告
     */
    @IBAction func actReport(sender: UIBarButtonItem) {
        if (!self.chkTestingData(showPopMsg: true)) {
            return
        }
        
        if (dictMember["memberid"] == nil) {
            pubClass.popIsee(self, Msg: pubClass.getLang("mead_selmemberfirst"))
            return
        }
        
        // 跳轉 MEAD 報告頁面
        self.performSegueWithIdentifier("RecordDetail", sender: self.getPreSaveData(aryTestingData))
    }
    
    /**
     * act, UIBarButtonItem, 資料存檔
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        /*
        if (!self.chkTestingData(showPopMsg: true) || self.isDataSave == true) { return
        }
        
        if (dictMember["memberid"] == nil) {
            pubClass.popIsee(self, Msg: pubClass.getLang("mead_selmemberfirst"))
            return
        }
        */

        // 檢測數值重新整理為 dict array, key 對應 MeadCFG 的 'D_ARY_MEADDBID'
        //let dictRS = self.getPreSaveData(aryTestingData)
        let dictRS = self.getTestVal()
        
        var aryTmp: Array<Dictionary<String, String>> = []
        let aryKey = (mMeadCFG.D_ARY_MEADDBID).componentsSeparatedByString(",")
        let aryVal = (dictRS["val"]!).componentsSeparatedByString(",")
        
        for i in (0..<aryKey.count) {
            aryTmp.append(["id": aryKey[i], "val": aryVal[i]])
        }
        
        // 產生 'arg0' dict array data
        var dictArg0: Dictionary<String, AnyObject>! = dictRS
        dictArg0["key"] = aryTmp
        
        // http 連線參數設定
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "mead"
        dictParm["act"] = "mead_senddata"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
        
        print(dictParm)
        return
        
        // HTTP 開始連線
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            // 儲存成功
            if (dictHTTPSRS["result"] as! Bool == true) {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("datasavecompleted"))
                return
            }
            
            // 儲存失敗，直接跳離
            self.mBTMeadService.BTDisconn()
            self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })

        return
    }
    
    /**
     * act, 點取 '重測' button
     */
    @IBAction func actReset(sender: UIBarButtonItem) {
        pubClass.popConfirm(self, aryMsg: ["", pubClass.getLang("mead_resetmsg")], withHandlerYes: {

            self.CURR_STATU = self.STATU_READY
            self.currValCount = 0  // 目前檢測數值計算加總的次數
            self.mapTestValCount = [:] // 檢測數值 => 出現次數, 目的取得最多次數的 val
            self.aryTestingData = self.mMeadCFG.getAryAllTestData()
            self.moveCollectCell(0)
            self.isDataSave = false
            
            }, withHandlerNo: {}
        )
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        // BT 強制中斷
        mBTMeadService.BTDisconn()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    * TODO 測試資料
    */
    private func getTestVal() -> Dictionary<String, String> {
        var dictRS: Dictionary<String, String> = [:]
            
        dictRS["memberid"] = "MT000081"
        dictRS["avgL"] = "43"
        dictRS["gender"] = "M"
        dictRS["avgH"] = "73"
        dictRS["age"] = "30"
        dictRS["avg"] = "58"
        dictRS["membername"] = "唐凱文"
        dictRS["problem"] = "F202,F102,H102,H610,H410"
        dictRS["val"] = "60,68,56,40,47,30,88,70,47,48,43,48,48,48,47,48,50,44,107,110,59,62,64,62"
        dictRS["sdate"] = "20160329154836"
        
        return dictRS
    }
    
}