//
// Container
//

import UIKit
import Foundation
import Social

/**
 * 最新消息，發送預覽，分享第三方社群app
 */
class MsgPreview: UIViewController, UIDocumentInteractionControllerDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var mVCDocument: UIDocumentInteractionController!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableCell 自動調整高度
        tableList.estimatedRowHeight = 200.0
        tableList.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 產生 Item data
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellMsgPreview", forIndexPath: indexPath) as! MsgPreviewCell
        
        mCell.initView(dictData, PubClass: pubClass)
        
        
        return mCell
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MsgAddContainer") {
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '微信' button
     */
    @IBAction func actWechat(sender: UIButton) {
        /*
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                // Display the compose view controller.
                self.presentViewController(twitterComposeVC, animated: true, completion: nil)
        }
        else {
            self.showAlertMessage("You are not logged in to your Twitter account.")
        }
        return
        */
    }
    
    /**
     * act, 點取 'QQ' button
     */
    @IBAction func actQQ(sender: UIButton) {
        
        let activityViewController = UIActivityViewController(activityItems: [dictData["image"] as! UIImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    /**
     * act, 點取 'Line' button
     */
    @IBAction func actLine(sender: UIButton) {
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}