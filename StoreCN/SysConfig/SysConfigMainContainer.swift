//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class SysConfigMainContainer: UITableViewController, ConfigBTScaleDelegate {
    
     // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labScaleBond: UILabel!
    @IBOutlet weak var labScaleId: UILabel!
    
    // common property
    private var pubClass: PubClass!
    
    // 其他參數
    private var mConfigBTScale: ConfigBTScale!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // 取得藍牙體指計綁定資料
        setBTScaleStatTxt(pubClass.getPrefData("vscale") as! String)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableList.reloadData()
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // 根據 cell ident 執行 'performSegueWithIdentifier'
        let strident = tableView.cellForRowAtIndexPath(indexPath)!.reuseIdentifier
        
        if (strident == "cellConfigProfile") {
            self.performSegueWithIdentifier("ConfigProfile", sender: nil)
        }
        
        else if (strident == "cellConfigCourse") {
            self.performSegueWithIdentifier("ConfigCourse", sender: nil)
        }
        
        else if (strident == "cellConfigBTScale") {
            self.performSegueWithIdentifier("ConfigBTScale", sender: nil)
        }

        return
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 藍牙體指計頁面
        if (strIdent == "ConfigBTScale") {
            mConfigBTScale = segue.destinationViewController as! ConfigBTScale
            mConfigBTScale.delegate = self
        }
    }
    
    /**
    * 設定藍牙體脂計 Cell 文字
    */
    private func setBTScaleStatTxt(IdentID: String!) {
        var mColor = pubClass.ColorHEX(pubClass.dictColor["RedDark"])
        var strStat = pubClass.getLang("btsacel_bondN")
        
        if (IdentID.characters.count > 0) {
            mColor = pubClass.ColorHEX(pubClass.dictColor["GreenDark"])
            strStat = pubClass.getLang("btsacel_bondY")
        }
        
        labScaleBond.text = strStat
        labScaleBond.textColor = mColor
        labScaleId.text = IdentID
    }
    
    /**
    * #mark: 自訂的 ConfigBTScaleDelegate
    * 藍牙體脂計綁定狀態改變
    */
    func BTScaleBondChange(IdentID: String!) {
        setBTScaleStatTxt(IdentID)
    }
    
}