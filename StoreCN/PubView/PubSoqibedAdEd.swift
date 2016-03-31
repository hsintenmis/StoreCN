//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * protocol, PubSoqibedAdEd Delegate
 */
@objc protocol PubSoqibedAdEdDelegate {
    /**
     * 本頁面儲存成功通知
     */
    optional func saveSuccess(dictData: Dictionary<String, AnyObject>)
}

/**
 * SOQIBED 編輯頁面, containerView, 由會員主頁面/Mead檢測頁面 導入
 * 指定的會員已經購買 / Mead設定的 SOQIBED 編輯
 */
class PubSoqibedAdEd: UIViewController, PubSoqibedAdEdContDelegate {
    // delegate
    var delegate = PubSoqibedAdEdDelegate?()
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strMode: String! // 目前頁面模式, 'add' ,'edit' or 'del'
    
    // 其他參數
    private var mPubSoqibedAdEdCont: PubSoqibedAdEdCont!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * #mark: PubSoqibedAdEdContDelegate
     * 資料刪除通知
     */
    func delData() {
        strMode = "del"
        dataSaveProc()
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        //  SOQIBED 編輯頁面
        if (strIdentName == "PubSoqibedAdEdCont") {
            mPubSoqibedAdEdCont = segue.destinationViewController as! PubSoqibedAdEdCont
            mPubSoqibedAdEdCont.dictAllData = dictAllData
            mPubSoqibedAdEdCont.strMode = strMode
            mPubSoqibedAdEdCont.delegate = self
            
            return
        }
        
        return
    }
    
    /**
     * 資料 新增/編輯/刪除 http 連線儲存程序
     */
    private func dataSaveProc() {
        var dictArg0 = mPubSoqibedAdEdCont.getPageData()
        
        // 檢查是否有資料
        if (dictArg0 == nil) {
            return
        }
        
        // 檢查是否標記 '刪除'
        if (strMode == "del") {
            dictArg0!["del"] = "Y"
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
            let dictData = dictHTTPSRS["data"]!["content"] as! Dictionary<String, AnyObject>
            var strMsg = self.pubClass.getLang("err_trylatermsg")
            
            // 儲存成功, server 回傳該筆資料, 通知上層, 跳離
            if (bolRS == true) {
                if (self.strMode == "del") {
                    self.dictAllData = [:]
                    strMsg = self.pubClass.getLang("datadelcompleted")
                } else {
                    self.dictAllData = dictArg0!
                    self.dictAllData["mode"] = "edit"
                    self.dictAllData["index_id"] = dictData["index_id"] as! String

                    strMsg = self.pubClass.getLang("datasavecompleted")
                }
                
                self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: {self.delegate?.saveSuccess!(self.dictAllData)})
                })
                
                return
            }
            
            self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        return
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
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}