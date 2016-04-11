//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 訊息新增 輸入頁面
 */
class MsgAddContainer: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var swchType: UISwitch!
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var edTitle: UITextField!
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var imgPict: UIImageView!
    @IBOutlet weak var btnKBClose: UIButton!

    @IBOutlet weak var cellImage: UITableViewCell!
    
    // common property
    private var pubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    
    // 其他參數
    private let mImageClass = ImageClass()
    private let imagePicker = UIImagePickerController()  // 圖片選取 class
    private let maxWidth:CGFloat  = 320.0  // 圖片最大寬度
    private var imgNewSize: CGSize = CGSizeMake(0.0, 0.0)
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        // 初始與設定 VCview 內的 field
        labDate.text = pubClass.formatDateWithStr(strToday, type: 14)
        imgPict.contentMode = .ScaleAspectFit
        
        // textView 外觀樣式
        txtContent.layer.cornerRadius = 5
        txtContent.layer.borderWidth = 1
        txtContent.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtContent.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
        btnKBClose.alpha = 0.0
    }

    /**
    * #mark: UITableViewController
    * 動態指定 Table Cell height
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0:
            if (indexPath.row == 3) {
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
            let imgNew = info["UIImagePickerControllerOriginalImage"] as! UIImage
            var newW = imgNew.size.width
            var newH = imgNew.size.height
            
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
            self.imgPict.image = UIGraphicsGetImageFromCurrentImageContext()
            UIImageJPEGRepresentation(self.imgPict.image!, fltZipRate)
            UIGraphicsEndImageContext()
        }
        
        dismissViewControllerAnimated(true, completion: {
            // Image 重整
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
     * 取得本頁面欄位資料, parent 調用
     */
    func getPageData()->Dictionary<String, AnyObject>? {
        var dictRS: Dictionary<String, AnyObject> = [:]
        dictRS["del"] = "N"
        dictRS["image"] = ""
        
        // 檢查欄位
        if (edTitle.text == "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("message_err_title"))
            return nil
        }
        
        // 設定回傳資料
        dictRS["title"] = edTitle.text
        dictRS["content"] = txtContent.text
        dictRS["type"] = (swchType.on == true) ? "pub" : "draft"
        dictRS["title"] = edTitle.text
        dictRS["mime"] = "png"
        dictRS["image"] = ""
        
        if let imgTmp = imgPict.image {
            dictRS["image"] = mImageClass.ImgToBase64(imgTmp)
        }
        
        return dictRS
    }
    
    /**
     * act, 點取 '關閉鍵盤'
     */
    @IBAction func actKBClose(sender: UIButton) {
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
        imgNewSize = CGSizeMake(0.0, 0.0)
        self.imgPict.image = nil
        self.imgPict.frame.size = imgNewSize
        tableList.reloadData()
    }
    
}