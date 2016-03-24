//
// Container 直接加入一個 viewController
//

import UIKit
import Foundation

/**
 * protocol, TestingMemberSel Delegate
 */
protocol TestingMemberSelDelegate {
    /**
     * 本頁面點取 '會員 Item'  parent 執行相關程序
     */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath)
}

/**
 * 各個藍芽裝置檢測，選擇會員公用 VC
 */
class TestingMemberSel: UIViewController, PubMemberSelectDelegate {
    var delegate = TestingMemberSelDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, parent 設定設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = [] // 全部的會員
    var currIndexPath: NSIndexPath? // 已選擇的會員
    
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
        let mView = mPubMemberSelect.view
        mView.frame.size.height = contviewTable.layer.frame.height
        self.contviewTable.addSubview(mView)
        self.navigationController?.pushViewController(mPubMemberSelect, animated: true)
    }
    
    /**
     * #mark: PubMemberListDelegate, 會員列表，點取會員後跳離本頁面， parent 執行相關程序
     */
    func MemberSelected(MemberData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        // delegate 執行相關程序
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