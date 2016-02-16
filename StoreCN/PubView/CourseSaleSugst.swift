//
// ViewController
//

import UIKit
import Foundation

/**
 * 療程銷售 新增編輯, 療程建議說明，從 'PubCourseSaleAdEd' 導入
 */
class CourseSaleSugst: UIViewController {
    
    // @IBOutlet
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var parentClass: PubCourseSaleAdEd!

    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
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
    func initViewField() {
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * act, 點取 '完成' button
     */
    @IBAction func actDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

