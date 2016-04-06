//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * 會員預約療程編輯
 * 預約療程月曆頁面, 點取下方會員預約的療程, Container 跳轉主編輯界面
 */
class CourseReservEdit: UIViewController {
    
    // @IBOutlet
    
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictReservData: Dictionary<String, AnyObject> = [:]  // 預約的資料
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []  // 預設療程
    var aryCourseCust: Array<Dictionary<String, AnyObject>> = []  // 已購買療程
    var aryMember: Array<Dictionary<String, AnyObject>> = []  // 全部會員資料
    var strToday: String!
    
    // 其他參數
    private var mVCEditCont: CourseReservEditCont!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // Container 轉入編輯主頁面
        if (strIdent == "CourseReservEditCont") {
            mVCEditCont = segue.destinationViewController as! CourseReservEditCont
            mVCEditCont.strToday = self.strToday
            mVCEditCont.aryCourseDB = aryCourseDB
            mVCEditCont.aryMember = aryMember
            mVCEditCont.dictData = dictReservData
            mVCEditCont.aryCourseCust = aryCourseCust
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictReq = mVCEditCont.getPageData()
        if (dictReq == nil) {
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