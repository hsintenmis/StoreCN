//
//
//

import UIKit
import Foundation

/**
 * protocol, KBNavyBar Delegate
 */
protocol KBNavyBarDelegate {
    /**
     * UIToolbar, 點取'完成(確定)' btn
     */
    func KBBarDone()
    
    /**
     * UIToolbar, 點取'取消' btn
     */
    func KBBarCancel()
}

/**
 * 彈出的虛擬鍵盤, 上方的 UIToolbar,
 * 提供 取消/確定 button, 提供標題
 */
class KBNavyBar {
    var delegate = KBNavyBarDelegate?()
    
    private var pubClass: PubClass!
    
    /**
     * init
     */
    init() {
        pubClass = PubClass()
    }
    
    /**
     * 回傳處理好的 UIToolbar
     */
    func getKBBar(strTitle: String) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = false  // 半透明
        toolBar.barTintColor = pubClass.ColorHEX(pubClass.dictColor["silver"]!)  // 背景顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("select_ok"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(KBNavyBar.SelectDone))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // 自訂一個 label 作為 NavyBar 的 Title
        let labTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 14.0))
        //let labTitle = UILabel()
        //labTitle.sizeToFit()
        
        labTitle.text = strTitle
        //labTitle.font = UIFont(name: "System", size: 14)
        
        labTitle.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: labTitle)
        
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(KBNavyBar.SelectCancel))
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        //kbHeight = toolBar.frame.height + mPKView.frame.height
        
        return toolBar
    }
    
    /**
     * Picker 點取　'done'
     */
    @objc private func SelectDone() {
        delegate?.KBBarDone()
    }
    
    /**
     * Picker 點取　'cancel'
     */
    @objc private func SelectCancel() {
        delegate?.KBBarCancel()
    }
    
}