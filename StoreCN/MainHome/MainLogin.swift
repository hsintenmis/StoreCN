//
// TextView Delegate 直接在 storyboard 設定
//

import UIKit
import Foundation

/**
 * 本專案首頁，USER登入頁面
 */
class MainLogin: UIViewController, PubClassDelegate {

    // @IBOutlet
    @IBOutlet weak var edAcc: UITextField!
    @IBOutlet weak var edPsd: UITextField!
    @IBOutlet weak var swchSave: UISwitch!
    @IBOutlet weak var labVer: UILabel!
    
    // public property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    let mJSONClass = JSONClass()
    let mFileMang = FileMang()
    
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass.mDelege = self
        dictPref = pubClass.getPrefData()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        self.pubClass.ReloadAppDelg()
        dictPref = pubClass.getPrefData()
        initViewField()
        
        dispatch_async(dispatch_get_main_queue(), {

        })
    }
    
    /**
     * viewWillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        edAcc.text = dictPref["acc"] as? String
        edPsd.text = dictPref["psd"] as? String
        swchSave.setOn((dictPref["issave"] as! Bool), animated: false)

        labVer.text = pubClass.getLang("version") + ":" + (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
    }

    /**
     * user 登入資料送出, HTTP 連線檢查與初始
     */
    func StartHTTPConn() {
        // acc, psd 檢查
        if ((edAcc.text?.isEmpty) == true || (edPsd.text?.isEmpty) == true) {
            pubClass.popIsee(mVCtrl, Msg: pubClass.getLang("err_accpsd"))
            
            return
        }
        
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = edAcc.text?.uppercaseString;
        dictParm["psd"] = edPsd.text;
        //dictParm["page"] = "memberdata";
        //dictParm["act"] = "memberdata_login";
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVCtrl, ConnParm: dictParm)
    }
    
    /**
     * @mark: pubClass Delegate
     * HTTP 連線後取得連線結果
     */
    func HttpResponChk(dictRS: Dictionary<String, AnyObject>, AlertVC vcPopLoading: UIAlertController) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            vcPopLoading.title = pubClass.getLang("sysprompt")
            vcPopLoading.message = pubClass.getLang(dictRS["msg"] as? String)
            vcPopLoading.addAction(UIAlertAction(title:pubClass.getLang("i_see"), style: UIAlertActionStyle.Default, handler:nil))
            
            return
        }
        
        // 關閉 'vcPopLoading'
        vcPopLoading.dismissViewControllerAnimated(true, completion: {
            self.analyHTTPRespon(dictRS)
        })
    }
    
    /**
     * 解析 HTTP 連線結果，執行後續相關程序
     */
    private func analyHTTPRespon(dictRS: Dictionary<String, AnyObject>!) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            self.pubClass.popIsee(self.mVCtrl, Msg: dictRS["msg"] as! String)
            return
        }
        
        /* 解析正確的 http 回傳結果，執行後續動作,
        jobj Data 資料：mead, member, pict(會員照片檔名) */
        let dictData = dictRS["data"]!["content"]!
        
        // 取得 MEAD DB jobj data,轉為 string 存檔
        let dictMeadDB = dictData!["mead"] as! Dictionary<String, AnyObject>
        mFileMang.write(pubClass.filenameMEADDB, strData: mJSONClass.DictAryToJSONStr(dictMeadDB))
        
        // 資料存入 'Prefer'
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        
        if (swchSave.on == true) {
            mPref.setObject(edAcc.text, forKey: "acc")
            mPref.setObject(edPsd.text, forKey: "psd")
            mPref.setObject(true, forKey: "issave")
        }
        else {
            mPref.setObject("", forKey: "acc")
            mPref.setObject("", forKey: "psd")
            mPref.setObject(false, forKey: "issave")
        }
        
        mPref.synchronize()
        
        // 設定全域變數
        pubClass.setAppDelgVal("V_USRACC", withVal: edAcc.text!)
        pubClass.setAppDelgVal("V_USRPSD", withVal: edPsd.text!)
        
        // 跳轉至指定的名稱的Segue頁面, 傳遞參數
        self.performSegueWithIdentifier("MainMenu", sender: dictData)
    }
    
    /**
    * Segue 跳轉頁面
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "MainMenu") {
            let mVC = segue.destinationViewController as! MainMenu
            let dictData = sender as! Dictionary<String, AnyObject>
            
            if let aryData = dictData["member"] {
                mVC.aryMember = aryData as! Array<Dictionary<String, String>>
            }
            
            if let aryData = dictData["pict"] {
                mVC.aryPict = aryData as! Dictionary<String, String>
            }
            
            return
        }
        
        return
    }

    /**
     * #mark: TextView Delegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == edAcc {
            edPsd.becomeFirstResponder();
            return true
        }
        
        if textField == edPsd {
            edPsd.resignFirstResponder()
            StartHTTPConn() // 執行 http 連線程序
            return true
        }
        
        return true
    }
    
    /**
     * 鍵盤: 处理弹出事件
     */
    func keyboardWillShow(notification:NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let width = self.view.frame.size.width;
            let height = self.view.frame.size.height;
            let rect = CGRectMake(0.0, -156,width,height);
            self.view.frame = rect
        }
    }

    /**
     * 鍵盤: 处理收回事件
     */
    func keyboardWillHide(notification:NSNotification) {
        //self.view.addSubview(logoArea)
        let width = self.view.frame.size.width;
        let height = self.view.frame.size.height;
        let rect = CGRectMake(0.0, 0,width,height);
        self.view.frame = rect
    }
    
    /**
    * act, 點取 '登入' button
    */
    @IBAction func actLogin(sender: UIButton) {
        StartHTTPConn()
    }
    

    
}

