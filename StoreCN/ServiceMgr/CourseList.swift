//
// Container, 使用 addSubview 加入公用的 tableview class
//

import UIKit
import Foundation

/**
 * 療程管理，列表 + 刪除 功能
 */
class Courselist: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var contviewList: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // table data 設定
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    private var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    private var mCourseData: Dictionary<String, AnyObject> = [:]  // 選擇的療程
    private var currIndexPath: NSIndexPath?  // 目前 TableView 的 IndexPath
    
    // 已購買的療程選擇, 公用 class
    private var mPubCourseSelect: PubCourseSelect!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        
        // 檢查資料
        aryCourseDB = dictAllData["course"] as! Array<Dictionary<String, AnyObject>>
        
        if let tmpData = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseData = tmpData
        }
        
        if let tmpData = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        }
        
        // 檢查是否有資料
        if (aryMember.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
        
        // 初始, 已購買的療程選擇, 公用 class
        mPubCourseSelect = storyboard!.instantiateViewControllerWithIdentifier("PubCourseSelect") as! PubCourseSelect
        mPubCourseSelect.aryCourseData = aryCourseData
        mPubCourseSelect.aryCourseDB = aryCourseDB
        mPubCourseSelect.aryMember = aryMember
        mPubCourseSelect.strToday = strToday
        mPubCourseSelect.currIndexPath = currIndexPath
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // !! container 直接加入 'PubMemberList'
        let mView = mPubCourseSelect.view
        mView.frame.size.height = contviewList.layer.frame.height
        self.contviewList.addSubview(mView)
        self.navigationController?.pushViewController(mPubCourseSelect, animated: true)
        
        dispatch_async(dispatch_get_main_queue(), {

        })
    }
    
    /**
     * #mark: CourseDataSelected, 療程列表點取項目後執行相關程序
     */
    func CourseDataSelected(CourseData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        currIndexPath = indexPath
        mCourseData = dictData
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}