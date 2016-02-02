//
// CollectionView delegate 直接由 storyboard 設定
// ContainerView
// MemberMainPagerDelegate, 當滑動完成時，本頁面執行相關程序
// import PagerView class
//

import UIKit
import Foundation

/**
 * 會員主頁面，編輯/刪除, 提供該會員各項資料檢視
 *
 * pager 頁面
 *   疗程纪录/能量检测/SOQIBed/购货纪录/健康纪录
 */
class MemberMain: UIViewController, MemberMainPagerDelegate {
    
    // @IBOutlet
    @IBOutlet weak var imgPict: UIImageView!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labJoin: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labBirth: UILabel!
    
    @IBOutlet weak var coltviewMenu: UICollectionView!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // public, parent 設定
    var strToday = ""
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // Container 的 VC, 從 'prepareForSegue' 實體化
    private var mMemberMainPager: MemberMainPager!
    
    // CollectionView 相關設定
    private let aryMenuName = ["course", "mead", "soqibed", "purchase", "health"]
    private var currIndexPath = NSIndexPath(forRow: 0, inSection:0)
    
    // 顏色
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0", "blue":"66CCFF", "black":"000000", "green":"99CC33"]
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
        
        self.initViewField()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // HTTP 連線取得資料
        StartHTTPConn()
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        // 設定會員資料
        let strGender = pubClass.getLang("gender_" + (dictMember["gender"] as! String))
        let strAge = (dictMember["age"] as! String) + pubClass.getLang("name_age")
        let strId = dictMember["memberid"] as! String
        
        labId.text = strId
        labName.text = dictMember["membername"] as? String
        labGender.text = strGender + " " + strAge
        labTel.text = dictMember["tel"] as? String
        
        labJoin.text = pubClass.formatDateWithStr(dictMember["sdate"] as! String, type: "8s")
        labBirth.text = pubClass.formatDateWithStr(dictMember["birth"] as! String, type: "8s")
        
        // 圖片
        let imgURL = pubClass.D_WEBURL + "upload/HP_" + strId + ".png"
        imgPict.downloadImageFrom(link: imgURL, contentMode: UIViewContentMode.ScaleAspectFit)
    }
    
    /**
     * HTTP 連線取得資料
     */
    private func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getdata"
        dictParm["arg0"] = dictMember["memberid"] as? String
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVCtrl, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     * 回傳以下：
     *   資料: course, soqibed, mead, purchase
     *   固定: datacourse, 療程資料庫
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            dispatch_async(dispatch_get_main_queue(), {
                self.pubClass.popIsee(self.mVCtrl, Msg: self.pubClass.getLang(dictRS["msg"] as? String), withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
            
            return
        }
        
        /* 解析正確的 http 回傳結果，執行後續動作 */
        let dictData = (dictRS["data"]!["content"]!)!
        strToday = dictData["today"] as! String
        
        // 設定各個 Pager Table 需要的 datasource 
        var dictAllData: Dictionary<String, Array<Dictionary<String, AnyObject>>> = [:]
        
        for strDataName in aryMenuName {
            if (strDataName == "health") {
                continue
            }
            
            if let tmpData = dictData[strDataName] as? Array<Dictionary<String, AnyObject>> {
                dictAllData[strDataName] = tmpData
            }
        }
        
        // 手動執行
        print("performSegueWithIdentifier")
        self.performSegueWithIdentifier("MemberMainPager", sender: dictAllData)
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
        let mCell: MemberMainColtViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellMemberMainColtView", forIndexPath: indexPath) as! MemberMainColtViewCell
        
        let position = indexPath.row
        mCell.labTitle.text = pubClass.getLang("member_main_" + aryMenuName[position])
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        var strColor = "silver"
        
        if (indexPath == currIndexPath) {
            strColor = "blue"
        }
        mCell.backgroundColor = pubClass.ColorHEX(dictColor[strColor])
        
        return mCell
    }
    
    /**
     * #mark: CollectionView, Cell click
     * 點取 collection cell
     */
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        currIndexPath = indexPath
        coltviewMenu.reloadData()
        
        // 設定 pager 'MOVE'
        mMemberMainPager.moveToPage(indexPath.row)
    }
    
    /**
     * #mark: 自訂的 delegate 'MemberMainPagerDelegate'
     */
    func PageTransFinish(mRow: Int) {
        currIndexPath = NSIndexPath(forRow: mRow, inSection:0)
        
        // CollectionView 更新
        coltviewMenu.scrollToItemAtIndexPath(currIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        coltviewMenu.reloadData()
    }

    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        // Container Pager
        if (strIdentName == "MemberMainPager") {
            let mVC = segue.destinationViewController as! MemberMainPager
            
            print("prepareForSegue")
            
            mMemberMainPager = mVC
            mMemberMainPager.delegateMemberMainPager = self
            mMemberMainPager.aryMenuName = aryMenuName
            mMemberMainPager.dictAllData = sender as! Dictionary<String, Array<Dictionary<String, AnyObject>>>
            
            return
        }
        
        return
    }

    
    /**
     * act, 點取 'XX' button
     */
    @IBAction func actAdd(sender: UIBarButtonItem) {
        
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

