//
// TextView Delegate 直接在 storyboard 設定
//

import UIKit
import Foundation

/**
 * 本專案首頁，USER登入頁面
 */
class MainLogin: UIViewController {

    // @IBOutlet
    @IBOutlet weak var edAcc: UITextField!
    @IBOutlet weak var edPsd: UITextField!
    @IBOutlet weak var swchSave: UISwitch!
    @IBOutlet weak var labVer: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    // common property
    private let pubClass: PubClass = PubClass()
    private let mJSONClass = JSONClass()
    private let mFileMang = FileMang()
    private var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        dictPref = pubClass.getPrefData()
        
        btnLogin.layer.cornerRadius = 5
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        self.pubClass.ReloadAppDelg()
        dictPref = pubClass.getPrefData()
        initViewField()
    }
    
    /**
     * viewWillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainLogin.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainLogin.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
     * viewWill Disappear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        // 註銷监听键盘事件函数
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
     * view StatusBarHidden(
     */
    override func prefersStatusBarHidden() -> Bool {
        return true
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
            pubClass.popIsee(self, Msg: pubClass.getLang("err_accpsd"))
            
            return
        }
        
        // 連線 HTTP post/get 參數
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = edAcc.text?.uppercaseString;
        dictParm["psd"] = edPsd.text;
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        /* 解析正確的 http 回傳結果，執行後續動作,
        jobj Data 資料：mead, member, pict(會員照片檔名) */
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            dispatch_async(dispatch_get_main_queue(), {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang(dictRS["msg"] as? String))
            })
            
            return
        }
        
        // 解析資料
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
        
        if let intTmp = dictRS["data"]!["role"] as? Int {
            pubClass.setAppDelgVal("V_USRROLE", withVal: intTmp)
        } else {
            self.pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"))
            
            return
        }
        
        // 跳轉至指定的名稱的Segue頁面, 傳遞參數
        self.performSegueWithIdentifier("MainMenu", sender: dictData)
    }
    
    /**
    * Segue 跳轉頁面
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let strIdent = segue.identifier
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