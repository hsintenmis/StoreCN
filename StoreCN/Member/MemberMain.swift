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
class MemberMain: UIViewController, MemberMainPagerDelegate, PubClassDelegate {
    // delegate
    var delegate = PubClassDelegate?()
    
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
    let pubClass: PubClass = PubClass()
    
    // public, parent 設定
    var strToday = ""
    var dictMember: Dictionary<String, AnyObject> = [:]  // 會員基本資料
    var dictAllData: Dictionary<String, AnyObject> = [:]  // 該會員全部相關資料
    
    // Container 的 VC, 從 'prepareForSegue' 實體化
    private var mMemberMainPager: MemberMainPager!
    
    // CollectionView 相關設定
    private let aryMenuName = ["course", "mead", "soqibed", "purchase", "health"]
    private var currIndexPath = NSIndexPath(forRow: 0, inSection:0)
    
    // 其他參數
    private var mMemberHttpData: MemberHttpData!  // http 連線取得會員全部料
    private var bolDataChangMember = false  // 會員基本資料是否異動
    private var bolParentReload = false  // 上層是否要更新
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 會員資料相關參數
        mMemberHttpData = MemberHttpData(VC: self)
        
        self.initMemberProfile()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolDataChangMember == true) {
            bolDataChangMember = false
            
            // 重新 http 連線取指定得會員對應的各項紀錄資料
            mMemberHttpData.connGetData(dictMember["memberid"] as! String, connCallBack: {
                (dictAllMemberData) -> Void in
                
                // 回傳資料失敗
                if (dictAllMemberData["result"] as! Bool != true) {
                    var errMsg = dictAllMemberData["err"] as! String
                    if (errMsg.characters.count < 1)  {
                        errMsg = self.pubClass.getLang("err_systemmaintain")
                    }
                    
                    // 跳離本頁面
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
                    
                    return
                }
                
                // 回傳資料重新設定參數
                self.dictAllData = dictAllMemberData
                self.dictMember = (dictAllMemberData["datamember"] as! Array<Dictionary<String, AnyObject>>)[0]
                self.strToday = dictAllMemberData["today"] as! String
                
                // 重整上方會員基本資料 view
                self.initMemberProfile()
            })
        }
    }
    
    /**
     * #mark: PubClassDelegate,  child 通知本頁面資料重整
     */
    func PageNeedReload(needReload: Bool) {
        bolParentReload = true
    }

    /**
     * #mark: PubClassDelegate,  child 通知本頁面資料重整
     * child 傳送 arg0, 根據 arg0 執行相關程序
     */
    func PageNeedReload(needReload: Bool, arg0: String?) {
        // 會員基本資料變動
        if (arg0 == "memberedit") {
            bolDataChangMember = true
            bolParentReload = true
            return
        }
        
        // 會員大頭照變動
        if (arg0 == "memberpict") {
            let imgURL = pubClass.D_WEBURL + "upload/HP_" + (dictMember["memberid"] as! String) + ".png"
            imgPict.downloadImageFrom(link: imgURL, contentMode: UIViewContentMode.ScaleAspectFit)
            return
        }
    }
    
    /**
     * 初始與設定上方會員基本資料 內的 field
     */
    func initMemberProfile() {
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
        mCell.backgroundColor = pubClass.ColorHEX(pubClass.dictColor[strColor])
        
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
        
        // Container Pager, 療程/Mead/Soqibed/購貨/健康 各個頁面
        if (strIdentName == "MemberMainPager") {
            let mVC = segue.destinationViewController as! MemberMainPager
            
            mMemberMainPager = mVC
            mMemberMainPager.aryMenuName = aryMenuName
            mMemberMainPager.dictAllData = dictAllData
            mMemberMainPager.dictMember = dictMember
            mMemberMainPager.strToday = strToday
            
            mMemberMainPager.delegateMemberMainPager = self
            mMemberMainPager.delegatePubClass = self
            
            return
        }
        
        // 會員編輯 VC
        if (strIdentName == "MemberEdit") {
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "edit"
            mVC.dictMember = dictMember
            mVC.delegate = self
            
            return
        }
        
        // 會員大頭照
        if (strIdentName == "MemberPict") {
            let mVC = segue.destinationViewController as! MemberPict
            mVC.strMemberID = dictMember["memberid"] as! String
            mVC.delegate = self
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        // 本頁面資料是否有變動
        if (bolParentReload == true) {
            delegate?.PageNeedReload!(true)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}