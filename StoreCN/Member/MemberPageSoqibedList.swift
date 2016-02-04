//
// TableView, 直接調用本 class
//

import UIKit
import Foundation

/**
 * 療程列表
 */
class MemberPageSoqibedList: UITableViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // 其他參數設定
    var arySoqibedData: Array<Dictionary<String, AnyObject>> = []  // parent 設定
    var strToday = ""
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
        
        labNoData.alpha = 0.0
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if (self.arySoqibedData.count < 1) {
                self.labNoData.alpha = 1.0
            }
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return arySoqibedData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (arySoqibedData.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = arySoqibedData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellMemberSoqibedList", forIndexPath: indexPath) as! CourseListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    
}

