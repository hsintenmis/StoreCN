//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation
import MessageUI  // 簡訊發送

/**
 * 今日提醒, 聯絡會員, Container
 */
class RemindContact: UIViewController, RemindContactContDelegate, MFMessageComposeViewControllerDelegate {
    
    // common property
    private let pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject>!
    var strType: String! // 辨識標記, 預約/到期
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * #mark: RemindContactContDelegate
     *'撥號', '發送簡訊'
     */
    func SendDone(dictData: Dictionary<String, String>!, strType: String!) {
        // 檢查設備是否可撥號
        if ( MFMessageComposeViewController.canSendText() != true ) {
            pubClass.popIsee(self, Msg: pubClass.getLang("device_cannotdial"))
            
            return
        }
        
        // 簡訊發送
        if (strType == "SMS") {
            let mVCSMS = MFMessageComposeViewController()
            mVCSMS.body = dictData["msg"]
            mVCSMS.recipients = [dictData["tel"]!]
            mVCSMS.messageComposeDelegate = self
            
            self.presentViewController(mVCSMS, animated: true, completion: nil)
            
            return
        }
        
        // 撥號
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(dictData["tel"]!)") {
            let application:UIApplication = UIApplication.sharedApplication()
            
            print(application.canOpenURL(phoneCallURL))
            
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
            else {
                pubClass.popIsee(self, Msg: pubClass.getLang("device_cannotdial"))
                return
            }
        }
        
        return
    }
    
    /**
     * #mark: MFMessageComposeViewControllerDelegate
     * 簡訊發送完成
     */
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        print(result)
        
        controller.dismissViewControllerAnimated(true, completion: {})
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // Container 轉入 撥號/SMS 主頁面
        if (strIdent == "RemindContactCont") {
            let mVC = segue.destinationViewController as! RemindContactCont
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            mVC.strType = strType  // 辨識標記, 預約/到期
            mVC.delegate = self
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}