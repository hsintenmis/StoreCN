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
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    /** 
     * 檢測數值 array data, 從 MeadConfig 初始取得<P>
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
    private var mMeadCFG = MeadCFG() // MEAD 設定檔
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // 量測數值與會員資料
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    
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
        
        if (isEnable == true) {
            imgLoading.stopAnimating()
            imgBody.alpha = 1.0
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
        dictRequest["member"] = MemberData
        
        // 會員名稱與相關資料重新顯示
        let strGender = pubClass.getLang("gender_" + (dictRequest["member"]!["gender"] as! String))
        let strAge = dictRequest["member"]!["age"] as! String + pubClass.getLang("name_age")
        let strHeight = dictRequest["member"]!["height"] as! String + "cm"
        let strMemberInfo = strGender + strAge + ", " + strHeight
        
        labGender.text = strMemberInfo
        labName.text = dictRequest["member"]!["membername"] as? String
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
        
        // 重新改變狀態
        if (mBTMeadService.BT_ISREADYFOTESTING) {
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
        // CURR_STATU = STATU_FINISH;
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
            
            break
            
        // 藍芽設備回傳資料
        case "BT_data":
            // 有回傳資料 Int val
            if (result == true) {
                labTestVal.text = "\(intVal!)"
                //print(intVal)
            }
            
            break
            
        default:
            break
        }
    }

    
    /**
     * act, UIBarButtonItem, 顯示檢測報告
     */
    @IBAction func actReport(sender: UIBarButtonItem) {

    }
    
    /**
     * act, UIBarButtonItem, 資料存檔
     */
    @IBAction func actSave(sender: UIBarButtonItem) {

    }
    
    /**
     * act, 點取 '重測' button
     */
    @IBAction func actReset(sender: UIBarButtonItem) {
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        // BT 強制中斷
        mBTMeadService.BTDisconn()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}