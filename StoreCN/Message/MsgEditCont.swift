//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 訊息編輯 輸入頁面
 */
class MsgEditCont: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var swchType: UISwitch!
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var edTitle: UITextField!
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var imgPict: UIImageView!
    @IBOutlet weak var btnPreview: UIButton!
    @IBOutlet weak var btnKBClose: UIButton!
    @IBOutlet weak var btnRecover: UIButton!
    
    @IBOutlet weak var cellImage: UITableViewCell!
    
    // common property
    private var pubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    var dictData: Dictionary<String, AnyObject>!
    
    // 圖片相關參數
    private let mImageClass = ImageClass()
    private let imagePicker = UIImagePickerController()  // 圖片選取 class
    private let maxWidth:CGFloat  = 320.0  // 圖片最大寬度
    private var imgNewSize: CGSize = CGSizeMake(0.0, 0.0)
    
    private var strURL: String = ""  // 原始圖片 URL
    private var imgOrg = UIImage() // 原始圖片
    private var bolReloadImg = true  // 首次進入頁面，圖片 http URL 讀取
    private var strImgStat = "none"  // 原始org /空白none /新圖片new
    
    // 其他參數
    private var bolReload = true
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        // 圖片相關, URL
        if (dictData["pict"] as! String != "") {
            strURL = pubClass.D_WEBURL + "upload/" + (dictData["pict"] as! String)
        }
        imgPict.contentMode = .ScaleAspectFit
        
        // 初始與設定 VCview 內的 field
        labDate.text = pubClass.formatDateWithStr(dictData["sdate"] as! String, type: 14)
        edTitle.text = dictData["title"] as? String
        txtContent.text = dictData["content"] as? String
        swchType.on = (dictData["pict"] as! String == "pub") ? true : false
        
        // textView 外觀樣式
        txtContent.layer.cornerRadius = 5
        txtContent.layer.borderWidth = 1
        txtContent.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtContent.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
        
        btnPreview.layer.cornerRadius = 5
        btnKBClose.alpha = 0.0
        btnRecover.alpha = (strURL != "") ? 1.0 : 0.0
    }
    
    /**
    * view DidAppear
    */
    override func viewDidAppear(animated: Bool) {
        // 首次進入本頁面, 讀取 URL 圖片顯示
        if (bolReloadImg == true) {
            bolReloadImg = false
            
            if (strURL != "") {
                mImageClass.HTTPConn(self, strURL: strURL, callBack: { (mNewImage) in
                    if (mNewImage != nil) {
                        self.recoverOrgImg(mNewImage!)
                    }
                })
            }
            
            return
        }
    }
    
    /**
    * 初始/重設 圖片
    */
    private func recoverOrgImg(mImage: UIImage!) {
        strImgStat = "org"
        
        // 選擇的圖片寬高
        var newW = mImage.size.width
        var newH = mImage.size.height
        
        // 重新取得寬高
        if (newW >= maxWidth) {
            let mRatio = (maxWidth / newW)
            newW = CGFloat(Int(newW * mRatio))
            newH = CGFloat(Int(newH * mRatio))
        }

        // UIImage 圖片尺寸重新處理
        self.imgNewSize = CGSizeMake(newW, newH)
        let mRect = CGRectMake(0, 0, newW, newH)  // 座標尺寸
        UIGraphicsBeginImageContextWithOptions(self.imgNewSize, false, 1.0)
        mImage.drawInRect(mRect)

        let mNewImg = UIGraphicsGetImageFromCurrentImageContext()
        let nsData = UIImageJPEGRepresentation(mNewImg, 1.0)
        UIGraphicsEndImageContext()
        imgOrg = UIImage(data: nsData!)!
        
        // TableView 重整
        tableList.reloadData()
        self.imgPict.image = imgOrg
        //self.imgPict.frame.size = CGSizeMake(newW, newH)
    }
    
    /**
     * #mark: UITableViewController
     * 動態指定 Table Cell height
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0:
            if (indexPath.row == 4) {
                return 150.0
            }
        case 1:
            return imgNewSize.height + 50
        default:
            return 44.0
        }
        
        return 50.0
    }
    
    /**
     * #mark: UIImagePickerController Delegate
     * 開啟圖片選擇 VC, 選擇圖片後設定到 UIImage
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // 選擇的圖片寬高
            let newImg = info["UIImagePickerControllerOriginalImage"] as! UIImage
            var newW = newImg.size.width
            var newH = newImg.size.height
            
            // 重新取得寬高
            if (newW > maxWidth) {
                let mRatio = (maxWidth / newW)
                newW = CGFloat(Int(newW * mRatio))
                newH = CGFloat(Int(newH * mRatio))
            }
            
            // 根據比例產生新圖片
            self.imgNewSize = CGSizeMake(newW, newH)
            let fltZipRate: CGFloat = 0.7 // 壓縮比, 壓縮圖片
            let mRect = CGRectMake(0, 0, newW, newH)  // 座標尺寸
            
            UIGraphicsBeginImageContextWithOptions(self.imgNewSize, false, 1.0)
            pickedImage.drawInRect(mRect)
            
            // 重新設定 UIImage
            let mNewImg = UIGraphicsGetImageFromCurrentImageContext()
            let nsData = UIImageJPEGRepresentation(mNewImg, fltZipRate)
            UIGraphicsEndImageContext()
            self.imgPict.image = UIImage(data: nsData!)
        }
        
        dismissViewControllerAnimated(true, completion: {
            // Image 重整
            self.strImgStat = "new"
            self.tableList.reloadData()
            self.imgPict.frame.size = self.imgNewSize
        })
    }
    
    /**
     * #mark: UIImagePickerController Delegate
     * 開啟圖片選擇 VC, 取消關閉
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == edTitle {
            textField.resignFirstResponder()
            
            return true
        }
        
        return false
    }
    
    /**
     * #mark: UITextViewDelegate
     * 虛擬鍵盤: 點取 TextView 開始輸入字元
     */
    func textViewDidBeginEditing(textView: UITextView) {
        btnKBClose.alpha = 1.0
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MsgPreview") {
            let mVC = segue.destinationViewController as! MsgPreview
            mVC.dictData = sender as! Dictionary<String, AnyObject>
            mVC.strToday = strToday
            
            return
        }
        
        return
    }
    
    /**
     * 取得本頁面欄位資料, parent 調用
     */
    func getPageData()->Dictionary<String, AnyObject>? {
        var dictRS: Dictionary<String, AnyObject> = [:]
        
        // 檢查欄位
        if (edTitle.text == "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("message_err_title"))
            return nil
        }
        
        // 設定回傳資料
        dictRS["sdate"] = dictData["sdate"]
        dictRS["title"] = edTitle.text
        dictRS["content"] = txtContent.text
        dictRS["image"] = nil
        
        if let imgTmp = imgPict.image {
            //dictRS["image"] = mImageClass.ImgToBase64(imgTmp)
            dictRS["image"] = imgTmp
        }
        
        return dictRS
    }
    
    /**
     * act, 點取 '關閉鍵盤'
     */
    @IBAction func actCloseKB(sender: UIButton) {
        btnKBClose.alpha = 0.0
        txtContent.resignFirstResponder()
    }
    
    /**
     * act, 點取 '選擇圖片', 開啟 UIImagePickerController
     */
    @IBAction func actSelPict(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /**
     * act, 點取 '清除圖片'
     */
    @IBAction func actClearPict(sender: UIButton) {
        strImgStat = "none"
        self.imgPict.image = nil
        self.imgNewSize = CGSizeMake(0.0, 0.0)
        self.imgPict.frame.size = self.imgNewSize
        tableList.reloadData()
    }
    
    /**
     * act, 點取 '回復圖片'
     */
    @IBAction func actRecoverPict(sender: UIButton) {
        if (strImgStat == "org") {
            return
        }
        self.recoverOrgImg(imgOrg)
    }
    
    /**
     * act, 點取 '發送預覽'
     */
    @IBAction func actPreview(sender: UIButton) {
        let dictRS = getPageData()
        
        if (dictRS != nil) {
            self.performSegueWithIdentifier("MsgPreview", sender: dictRS)
        }
    }
    
}