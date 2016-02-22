//
// Container 直接加入一個 viewController (直接加入 'PubMemberList')
//

import UIKit
import Foundation

/**
 * protocol, PdSaleMemberSel Delegate
 */
protocol PdSaleMemberSelDelegate {
    /**
     * 本頁面點取 '會員 Item'  parent 執行相關程序
     */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath)
}

/**
 * 會員選擇，從 [商品銷售] 頁面轉入
 */
class PdSaleMemberSel: UIViewController, PubMemberSelectDelegate {
    var delegate = PdSaleMemberSelDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 設定
    var strToday = ""
    var currIndexPath: NSIndexPath? // 已選擇的會員
    var aryMember: Array<Dictionary<String, AnyObject>> = [] // 全部的會員
    
    // 會員選擇公用 class
    private var mPubMemberSelect: PubMemberSelect!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        
        // 初始會員選擇公用 class
        mPubMemberSelect = storyboard!.instantiateViewControllerWithIdentifier("PubMemberList") as! PubMemberSelect
        mPubMemberSelect.delegate = self
        mPubMemberSelect.aryMember = aryMember
        mPubMemberSelect.currIndexPath = currIndexPath
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // !! container 直接加入 'PubMemberList'
        let mView = self.mPubMemberSelect.view
        mView.frame.size.height = self.contviewTable.layer.frame.height
        
        self.contviewTable.addSubview(mView)
        self.navigationController?.pushViewController(self.mPubMemberSelect, animated: true)
        
        dispatch_async(dispatch_get_main_queue(), {

        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
    }
    
    /**
     * #mark: PubMemberListDelegate, 會員列表，點取會員後跳離本頁面， parent 執行相關程序
     */
    func MemberSelected(MemberData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: {
            self.delegate?.MemberSeltPageDone(dictData, MemberindexPath: indexPath)
            }
        )
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

