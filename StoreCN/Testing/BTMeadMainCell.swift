//
// UICollectionViewCell
//

import Foundation
import UIKit

/**
 * 能量檢測儀 主頁面, 上方檢測項目 collectionView cell
 */
class BTMeadMainCell: UICollectionViewCell {
    @IBOutlet weak var labName: UILabel!
    
    private var pubClass: PubClass!
    
    /**
     * 初始與設定 Cell
     */
    func initView(dictItem: Dictionary<String, String>!, mPubClass: PubClass!, indexpath: NSIndexPath, selectedIndex: NSIndexPath!) {
        pubClass = mPubClass
        
        let strItemName = pubClass.getLang("mead_body_" + (dictItem["body"]! + dictItem["direction"]!)) + " " + dictItem["serial"]!
        labName.text = strItemName
        
        // 樣式/外觀/顏色
        self.layer.cornerRadius = 2
        
        var strColor = "gray"
        
        if (indexpath == selectedIndex) {
            strColor = "blue"
        }
        else if (dictItem["val"] != "0") {
            strColor = "green"
        }
        
        self.backgroundColor = pubClass.ColorHEX(pubClass.dictColor[strColor])
    }
}