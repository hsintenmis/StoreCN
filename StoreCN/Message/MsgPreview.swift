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
class MsgPreview: UIViewController, WXApiDelegate, TencentSessionDelegate, UIApplicationDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private let mImageClass = ImageClass()
    private var mVCDocument: UIDocumentInteractionController!
    
    // WeChat 相關參數
    
    // QQ 相關參數
    private var tencentOAuth: TencentOAuth!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WeChat 相關參數, 注册 app
        WXApi.registerApp("wxb4ba3c02aa476ea1", withDescription: "demo 2.0")
        
        // QQ 相關參數, 注册 app
        tencentOAuth = TencentOAuth(appId: "222222", andDelegate: self)
        
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
        return
    }
    
    /**
     * 取得 Cell View to UIImage
     */
    private func getCellViewImage() -> UIImage! {
        // 取得 'Cell' frame to Image
        let mCell = tableList.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        
        UIGraphicsBeginImageContextWithOptions(mCell.frame.size, false, 1.0)
        mCell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //UIImageJPEGRepresentation(image, 1.0)
        UIImagePNGRepresentation(image)
        
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
        // 發送圖片
        let image = self.getCellViewImage()
        let imgPre = UIImageJPEGRepresentation(image!, 0)
        let imgOrg = UIImageJPEGRepresentation(image, 1.0)
        
        // 分享到QQ
        let imgObj = QQApiImageObject.objectWithData(imgOrg, previewImageData: imgPre, title: "Share", description: "Image") as! QQApiObject
        let req = SendMessageToQQReq(content: imgObj)
        QQApiInterface.sendReq(req)
    }
    
    // MARK: QQ分享代理
    /**
     * #mark: TencentSessionDelegate
     */
    func tencentDidLogin() {
        print("登录AccessToken : \(tencentOAuth.accessToken)")
    }
    
    /**
     * #mark: TencentSessionDelegate
     */
    func tencentDidNotLogin(cancelled: Bool) {
        if cancelled { print("用户取消登录") }
        else { print("等录失败") }
    }
    
    /**
     * #mark: TencentSessionDelegate
     */
    func tencentDidNotNetWork() {
        print("无网络连接，请设置网络")
    }
    
    /**
     * act, 點取 'Line' button
     */
    @IBAction func actLine(sender: UIButton) {
        let image = self.getCellViewImage()
        let data = NSData(data: UIImagePNGRepresentation(image!)! )
        let mPastBD = UIPasteboard.generalPasteboard()
        mPastBD.setData(data, forPasteboardType: "public.png")
        let mNSURL = NSURL(string: "line://msg/image/" + mPastBD.name)
        UIApplication.sharedApplication().openURL(mNSURL!)

        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: UIApplicationDelegate
     * QQ SDK use
     */
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return TencentOAuth.HandleOpenURL(url)
    }
    
    /**
     * #mark: UIApplicationDelegate
     * QQ SDK use
     */
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return TencentOAuth.HandleOpenURL(url)
    }
 
}