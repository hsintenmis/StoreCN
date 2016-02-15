//
// Container直接加入一個 viewController
//

import UIKit
import Foundation

/**
 * 療程銷售 新增編輯, 會員選擇，從 'PubCourseSaleAdEd' 導入
 */
class CoursSaleMemberSel: UIViewController, PubMemberSelectDelegate {
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var parentClass: PubCourseSaleAdEd!
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = [] // 全部的會員
    
    private var currIndexPath: NSIndexPath!  // 目前 TableView 的 IndexPath
    
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
        // !! container 直接加入 'PubMemberList'
        let mPubMemberSelect = storyboard!.instantiateViewControllerWithIdentifier("PubMemberList") as! PubMemberSelect
        
        mPubMemberSelect.delegate = self
        mPubMemberSelect.aryMember = aryMember
        
        let mView = mPubMemberSelect.view
        mView.frame.size.height = contviewTable.layer.frame.height
        
        self.contviewTable.addSubview(mView)
        self.navigationController?.pushViewController(mPubMemberSelect, animated: true)
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * #mark: PubMemberListDelegate, 會員列表，點取會員執行相關程序
     */
    func MemberSelected(MemberData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        currIndexPath = indexPath
        
        // parent 執行相關程序
        self.dismissViewControllerAnimated(true, completion: {self.parentClass.selectMember(dictData)})
    }

    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

