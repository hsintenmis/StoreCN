//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * SOQIBED 編輯頁面, containerView, toip parent 為會員主頁面導入
 * 指定的會員已經購買療程對應的
 */
class SoqibedEdit: UIViewController {
    // delegate 
    var delegate = PubClassDelegate?()
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mSoqibedAdEdCont: SoqibedAdEdCont!
    private var strMode = "edit"
    private var bolDataSave = false  // 本頁面是否有資料存擋
    
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
        
        //  跳轉 SOQIBED 編輯主頁面
        if (strIdentName == "SoqibedAdEdCont") {
            mSoqibedAdEdCont = segue.destinationViewController as! SoqibedAdEdCont
            mSoqibedAdEdCont.dictAllData = dictAllData
            mSoqibedAdEdCont.strMode = strMode
            
            return
        }
        
        return
    }
    
    /**
     * 資料 編輯/刪除 http 連線儲存程序
     */
    private func dataSaveProc() {
        var dictArg0 = mSoqibedAdEdCont.getPageData()
        
        // 檢查是否有資料
        if (dictArg0 == nil) {
            return
        }
        
        // 檢查是否標記 '刪除'
        if (strMode == "del") {
            dictArg0!["del"] = "Y"
            dictArg0!["mode"] = "del"
        }
        
        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "soqibed"
        dictParm["act"] = "soqibed_senddata"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0!, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
        
        // HTTP 開始連線
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            let bolRS = dictHTTPSRS["result"] as! Bool
            var strMsg = self.pubClass.getLang("err_trylatermsg")
            
            // 儲存成功, 通知上層資料有變動
            if (bolRS == true) {
                // 編輯存擋
                if (self.strMode == "edit") {
                    strMsg = self.pubClass.getLang("datasavecompleted")
                    self.bolDataSave = true
                    self.pubClass.popIsee(self, Msg: strMsg)
                    
                    return
                }
                
                // 刪除完成
                else if (self.strMode == "del") {
                    strMsg = self.pubClass.getLang("datadelcompleted")
                    self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                        self.dismissViewControllerAnimated(true, completion: {self.delegate?.PageNeedReload!(true)})
                    })
                    
                    return
                }
            }

            self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        return
    }
    
    /**
     * act, 點取 '刪除' button
     */
    @IBAction func actDel(sender: UIBarButtonItem) {
        // 提醒視窗
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("delconfirmmsg")], withHandlerYes: {
                self.strMode = "del"
                self.dataSaveProc()
            }, withHandlerNo: {return})
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        dataSaveProc()
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            if (self.bolDataSave == true) {
                self.delegate?.PageNeedReload!(true)
            }
        })
    }
    
}