//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * SOQIBED 編輯頁面, containerView, 由會員主頁面轉入
 * 指定會員以購買的 SOQIBED 編輯
 */
class PubSoqibedAdEd: UIViewController {
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strMode: String! // 目前頁面模式, 'add' or 'edit'
    
    // 其他參數
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        //  SOQIBED 編輯頁面
        if (strIdentName == "PubSoqibedAdEdCont") {
            let mVC = segue.destinationViewController as! PubSoqibedAdEdCont
            mVC.dictAllData = dictAllData
            mVC.strMode = strMode
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}