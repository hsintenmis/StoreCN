//
// Container直接加入一個 viewController
//

import UIKit
import Foundation

/**
 * 會員主選單 Mead列表
 */
class MemberPageMeadList: UIViewController, PubMeadDataSelectDelegate {
    
    // @IBOutlet
    @IBOutlet weak var containerMeadList: UIView!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var mPubMeadDataSelect: PubMeadDataSelect!
    var aryMeadData: Array<Dictionary<String, String>> = []  // parent 設定
    var strToday = ""
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        
        // !! container 直接加入 'PubMemberList'
        mPubMeadDataSelect = storyboard!.instantiateViewControllerWithIdentifier("PubMeadDataList") as! PubMeadDataSelect
        
        mPubMeadDataSelect.delegate = self
        mPubMeadDataSelect.aryMeadData = aryMeadData
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            let mView = self.mPubMeadDataSelect.view
            mView.frame.size.height = self.containerMeadList.layer.frame.height
            
            self.containerMeadList.addSubview(mView)
            self.navigationController?.pushViewController(self.mPubMeadDataSelect, animated: true)
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * #mark: PubMeadDataSelectDelegate, Mead 資料列表，點取執行相關程序
     */
    func MeadDataSelected(MeadData dictData: Dictionary<String, String>, indexPath: NSIndexPath) {
        
        //print(dictData)
     }

    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let strIdent = segue.identifier

        return
    }
    
}

