//
// Container, 使用 addSubview 加入公用的 tableview class
//

import UIKit
import Foundation

/**
 * 會員已購買療程列表, 本頁面直接 http 連線取得資料
 */
class Courselist: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var contviewList: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數
    private var bolReload = true
    
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
        /*
        let strIdent = segue.identifier
        
        if (strIdent == "CourseSaleList") {
            let mVC = segue.destinationViewController as! PubCourseSelect
            return
        }
        */
        return
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}