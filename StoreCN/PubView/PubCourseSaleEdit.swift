//
// Container
//

import UIKit
import Foundation

/**
 * 公用, 會員療程銷售編輯
 */
class PubCourseSaleEdit: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictSaleData: Dictionary<String, AnyObject> = [:]  // 欄位資料 dict data
    var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var strToday = ""
    
    // 公用VC, 療程銷售新增/編輯 class
    var mPubCourseSaleAdEd: PubCourseSaleAdEd!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // !! container 直接加入 ViewControler
        mPubCourseSaleAdEd = storyboard?.instantiateViewControllerWithIdentifier("PubCourseSaleAdEd") as! PubCourseSaleAdEd
        
        mPubCourseSaleAdEd.dictSaleData = dictSaleData
        mPubCourseSaleAdEd.strToday = strToday
        mPubCourseSaleAdEd.aryCourseDB = aryCourseDB
        mPubCourseSaleAdEd.aryMember = aryMember
        mPubCourseSaleAdEd.strMode = "edit"
        
        let mView = mPubCourseSaleAdEd.view
        mView.frame.size.height = contviewTable.layer.frame.height
        mView.frame.size.width = contviewTable.layer.frame.width
        
        contviewTable.addSubview(mView)
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        mPubCourseSaleAdEd.saveData()
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}