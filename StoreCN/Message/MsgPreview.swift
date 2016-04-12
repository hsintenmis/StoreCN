//
// Container
// Lib ShareApp Key: 1182dbaa9fedd
//

import UIKit
import Foundation
import Social

/**
 * 最新消息，發送預覽，分享第三方社群app
 */
class MsgPreview: UIViewController, UIDocumentInteractionControllerDelegate, WXApiDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var mVCDocument: UIDocumentInteractionController!
    
    // WeChat 相關參數
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WeChat 相關參數, 注册 app
        WXApi.registerApp("wxb4ba3c02aa476ea1", withDescription: "demo 2.0")
        
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
     * #mark: WXApiDelegate
     */
    func onResp(resp: BaseResp!) {
        if resp.isKindOfClass(SendMessageToWXResp){//确保是对我们分享操作的回调
            if resp.errCode == WXSuccess.rawValue{//分享成功
                NSLog("分享成功")
            }else{//分享失败
                NSLog("分享失败，错误码：%d, 错误描述：%@", resp.errCode, resp.errStr)
            }
        }
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
     * 取得 Cell View to UIImage
     */
    private func getCellViewImage() -> UIImage! {
        // 取得 'Cell' frame to Image
        let mCell = tableList.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        //UIGraphicsBeginImageContext(mCell.frame.size)
        
        UIGraphicsBeginImageContextWithOptions(mCell.frame.size, false, 1.0)
        mCell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIImageJPEGRepresentation(image, 1.0)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /**
     * act, 點取 '微信' button
     * 'WXSceneSession' = 好友, 'WXSceneTimeline' = 朋友圈
     */
    @IBAction func actWechat(sender: UIButton) {
        let objType = (sender.restorationIdentifier == "btnWeChatFriend") ? WXSceneSession : WXSceneTimeline
        
        let message =  WXMediaMessage()
        
        // 取得 'Cell' frame to Image
        let image = self.getCellViewImage()
        
        //发送的图片
        let imageObject =  WXImageObject()
        imageObject.imageData = UIImagePNGRepresentation(image!)
        message.mediaObject = imageObject
        
        let req =  SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(objType.rawValue)
        WXApi.sendReq(req)
        
        return
    }
    
    /**
     * act, 點取 'QQ' button
     */
    @IBAction func actQQ(sender: UIButton) {
        
        let activityViewController = UIActivityViewController(activityItems: [self.getCellViewImage()], applicationActivities: nil)
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