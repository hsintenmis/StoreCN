//
//
//

import UIKit
import Foundation

/**
 * 指定會員, HTTP 連線取得各項資料
 * http 連線參數: 
 *  page => "memberdata",
 *  act  => "memberdata_getdata", arg0 => 會員 ID
 */
class MemberHttpData {
    // common property
    let pubClass: PubClass = PubClass()
    private var mVC: UIViewController!
    
    /**
    * init
    */
    init(VC: UIViewController) {
        mVC = VC
    }
    
    /**
     * http 連線取得資料
     * @return: Dictionary<String, AnyObject>, 加入欄位 'result' 判別,
     * true: 回傳會員全部相關資料, false: 加入錯誤訊息 'err'
     */
    func connGetData(MemberId: String!, connCallBack: (dictAllMemberData: Dictionary<String, AnyObject>!)->Void)  {
        var dictAllData: Dictionary<String, AnyObject> = [:]
        dictAllData["result"] = false
        
        // 連線 HTTP post/get 參數
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getdata"
        dictParm["arg0"] = MemberId
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVC, ConnParm: dictParm, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            // 任何錯誤回傳跳離
            if (dictRS["result"] as! Bool != true) {
                if let errMgs = dictRS["msg"] as? String  {
                    dictAllData["err"] = self.pubClass.getLang(errMgs)
                }
                
                connCallBack(dictAllMemberData: dictAllData)
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            var mDictData = (dictRS["data"]!["content"]) as! Dictionary<String, AnyObject>
            mDictData["result"] = true
            
            connCallBack(dictAllMemberData: mDictData)
            return
        })
        
        return
    }
    
}