//
// Container
//

import UIKit
import Foundation

/**
 *  主選單服務管理 - 療程銷售
 */
class CourseSale: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 療程DB資料, 全部會員資料
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 公用VC, 療程銷售新增/編輯 class
    var mPubCourseSaleAdEd: PubCourseSaleAdEd!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        
        // 檢查療程DB資料, 全部會員資料
        aryCourseDB = dictAllData["pd"] as! Array<Dictionary<String, AnyObject>>
        strToday = dictAllData["today"] as! String
        
        if let tmpData = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        }
        
        if (aryMember.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
        
        // !! container 直接加入 ViewControler
        mPubCourseSaleAdEd = storyboard?.instantiateViewControllerWithIdentifier("PubCourseSaleAdEd") as! PubCourseSaleAdEd
        
        mPubCourseSaleAdEd.strToday = strToday
        mPubCourseSaleAdEd.aryCourseDB = aryCourseDB
        mPubCourseSaleAdEd.aryMember = aryMember
        
        let mView = mPubCourseSaleAdEd.view
        mView.frame.size.height = contviewTable.layer.frame.height
        mView.frame.size.width = contviewTable.layer.frame.width
        
        contviewTable.addSubview(mView)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        print(mPubCourseSaleAdEd.getData())
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}