//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 最新消息，發送預覽 Cell
 */
class MsgPreviewCell: UITableViewCell {
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var labContent: UILabel!
    @IBOutlet weak var imgPict: UIImageView!
    
    // 圖片相關參數
    private let mImageClass = ImageClass()
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labTitle.text = ditItem["title"] as? String
        labDate.text = pubClass.formatDateWithStr((ditItem["sdate"] as! String), type: "14s")
        labContent.text = ditItem["content"] as? String
        
        imgPict.image = nil
        
        if let imgTmp = ditItem["image"] as? UIImage {
            imgPict.image = imgTmp
        }
        
        /*
        if let strTmp = ditItem["image"] as? String {
            if (strTmp != "") {
                imgPict.image = mImageClass.Base64ToImg(strTmp)
            }
        }
        */
    }
    
}