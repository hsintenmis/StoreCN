//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class MemberAdEd: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    var pubClass: PubClass!
    
    // public property, 上層 parent 設定
    var strToday: String!
    var strMode = "add"
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mMemberAdEdContainer: MemberAdEdContainer!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "containerMemberAdEd") {
            mMemberAdEdContainer = segue.destinationViewController as! MemberAdEdContainer
            mMemberAdEdContainer.strToday = strToday
            mMemberAdEdContainer.strMode = strMode
            mMemberAdEdContainer.dictMember = dictMember
            
            return
        }
        
        return
    }
    
    /**
    * 資料儲存程序
    */
    private func svaeData() {
        /*
         jobjRequestData.put("id", strMemberId);
         jobjRequestData.put("mode", strMode);
         
         jobjRequestData.put("name", edName.getText().toString());
         jobjRequestData.put("psd", edPsd.getText().toString());
         jobjRequestData.put("tel", edTel.getText().toString());
         jobjRequestData.put("email", edEmail.getText().toString());
         
         jobjRequestData.put("hteid", edHteId.getText().toString());
         jobjRequestData.put("cid", edId.getText().toString());
         jobjRequestData.put("id_wechat", edWechat.getText().toString());
         jobjRequestData.put("id_qq", edQQ.getText().toString());
         jobjRequestData.put("addr", edAddr.getText().toString());
         
         jobjRequestData.put("province", edProvince.getText().toString());
         jobjRequestData.put("zip", edZip.getText().toString());
         
         jobjRequestData.put("height", edHeight.getText().toString());
         jobjRequestData.put("weight", edWeight.getText().toString());
         jobjRequestData.put("birth", strBirth);
         jobjRequestData.put("gender", strGender);
        */
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        var dictRS = mMemberAdEdContainer.getPageData()
        
        if (dictRS == nil) {
            return
        }
        
        dictRS!["mode"] = strMode

        if (strMode == "edit") {
            dictRS!["id"] = dictMember["memberid"] as! String
        }
        
        print(dictRS)
        
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}