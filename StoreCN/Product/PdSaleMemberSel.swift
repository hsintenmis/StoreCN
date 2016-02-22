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
    
    // 其他參數設定, 上層 parent 設定
    var strToday = ""
    var indexPathMember: NSIndexPath?
    var aryMember: Array<Dictionary<String, AnyObject>> = [] // 全部的會員
    
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
        //mPubMemberSelect.currIndexPath = indexPathMember
        
        let mView = mPubMemberSelect.view
        mView.frame.size.height = contviewTable.layer.frame.height
        
        self.contviewTable.addSubview(mView)
        self.navigationController?.pushViewController(mPubMemberSelect, animated: true)

        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // !! container 直接加入 'PubMemberList'
        /*
        let mPubMemberSelect = storyboard!.instantiateViewControllerWithIdentifier("PubMemberList") as! PubMemberSelect
        
        mPubMemberSelect.delegate = self
        mPubMemberSelect.aryMember = aryMember
        mPubMemberSelect.currIndexPath = indexPathMember
        
        let mView = mPubMemberSelect.view
        mView.frame.size.height = contviewTable.layer.frame.height
        
        self.contviewTable.addSubview(mView)
        self.navigationController?.pushViewController(mPubMemberSelect, animated: true)
        */
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
    }
    
    /**
     * #mark: PubMemberListDelegate, 會員列表，點取會員執行相關程序
     */
    func MemberSelected(MemberData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        delegate?.MemberSeltPageDone(dictData, MemberindexPath: indexPath)
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

