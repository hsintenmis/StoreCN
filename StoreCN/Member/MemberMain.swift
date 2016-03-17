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
    var dictAllData: Dictionary<String, AnyObject> = [:]  // 該會員全部相關資料
    
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
        // http 連線取得資料
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
        
        // Container Pager, 療程/Mead/Soqibed/購貨/健康 各個頁面
        if (strIdentName == "MemberMainPager") {
            let mVC = segue.destinationViewController as! MemberMainPager
            
            mMemberMainPager = mVC
            mMemberMainPager.delegateMemberMainPager = self
            mMemberMainPager.aryMenuName = aryMenuName
            mMemberMainPager.dictAllData = dictAllData
            
            return
        }
        
        // 會員編輯 VC
        if (strIdentName == "MemberEdit") {
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "edit"
            mVC.dictMember = dictMember
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

