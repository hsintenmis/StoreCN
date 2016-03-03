//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 員工資料 新增/編輯
 */
class StaffAdEd: UIViewController {
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    private var pubClass: PubClass!
    
    // public, parent 設定
    var strMode: String = "add"
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // user 資料編輯頁面 calss
    private var mStaffAdEdContainer: StaffAdEdContainer!

    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        mStaffAdEdContainer = segue.destinationViewController as! StaffAdEdContainer
        mStaffAdEdContainer.strMode = strMode
        mStaffAdEdContainer.dictMember = dictMember
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        print(mStaffAdEdContainer.getPageData())
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

