//
// UITableViewController
//

import UIKit
import Foundation

/**
 * protocol, SugstChildPage Delegate
 */
protocol SugstChildPageDelegate {
    /**
     * Table Cell 點取，點取指定資料，實作點取後相關程序
     */
    func SubPageSubmitClick(TxtMsg: String, IdentName: String)
}

/**
 * 療程銷售建議文字產生，四個 VC 共用
 */
class SugstChildPage: UITableViewController {
    var delegate = SugstChildPageDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var coltviewPoint: UICollectionView!
    
    @IBOutlet weak var swchEpower: UISwitch!
    @IBOutlet weak var swchHot: UISwitch!
    @IBOutlet weak var swchSun: UISwitch!
    @IBOutlet weak var swchEre: UISwitch!
    
    @IBOutlet weak var segm0Epower: UISegmentedControl!
    @IBOutlet weak var segm1Epower: UISegmentedControl!
    @IBOutlet weak var segm0Hot: UISegmentedControl!
    @IBOutlet weak var segm1Hot: UISegmentedControl!
    @IBOutlet weak var segm0Sun: UISegmentedControl!
    @IBOutlet weak var segm0Ere: UISegmentedControl!
    
    @IBOutlet weak var labHot: UILabel!
    @IBOutlet weak var labSun: UILabel!
    @IBOutlet weak var edSun: UITextField!
    @IBOutlet weak var edEre: UITextField!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var strToday = ""
    
    // 目前 VC 的 'restorationIdentifier'
    // SugstEpower, SugstHot, SugstSun, SugstEre
    var strCurrIdent = "SugstEpower"
    
    // collectionView 參數
    private var aryColviewBol: Array<Bool> = []
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        
        // collectionView 參數, 經絡疏通重點共 14 個，紀錄是否有被 '選取'
        for _ in (0..<14) {
            aryColviewBol.append(false)
        }
        
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        strCurrIdent = self.restorationIdentifier!
        if (strCurrIdent == "SugstEpower") {
            coltviewPoint.alpha = 0.0
        }
        
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SugstChildPage.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            self.initViewField()
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        if (strCurrIdent == "SugstEpower") {
            coltviewPoint.reloadData()
            coltviewPoint.alpha = 1.0
        }
    }
    
    /**
     * #mark: UITextFieldDelegate, 點取 'return'
     */
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let width = self.view.frame.size.width;
        let height = self.view.frame.size.height;
        let rect = CGRectMake(0.0, 0.0, width,height);
        self.view.frame = rect
        
        return true;
    }
    
    /**
     * NSNotificationCenter
     * #mark: 鍵盤: 处理弹出事件
     */
    func keyboardWillShow(notification:NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let width = self.view.frame.size.width;
            let height = self.view.frame.size.height;
            let rect = CGRectMake(0.0, -160, width, height);
            self.view.frame = rect
        }
    }
    
    /**
     * #mark: CollectionView delegate, 經絡疏通重點
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #mark: CollectionView delegate, 經絡疏通重點
     * CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryColviewBol.count
    }
    
    /**
     * #mark: CollectionView delegate, 經絡疏通重點
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell: SugstChildColtCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSugstChildColt", forIndexPath: indexPath) as! SugstChildColtCell
        
        let strIndex = String(indexPath.row)
        
        // 樣式/外觀/顏色
        mCell.labName.text = pubClass.getLang("bodypoint_" + strIndex)
        mCell.layer.cornerRadius = 5

        if (aryColviewBol[indexPath.row] == true) {
             mCell.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["red"]!)).CGColor
        } else {
            mCell.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["silver"]!)).CGColor
        }
        
        return mCell
    }
    
    /**
     * #mark: CollectionView delegate, 經絡疏通重點
     * CollectionView, 點取 Cell
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        aryColviewBol[indexPath.row] = !aryColviewBol[indexPath.row]
        coltviewPoint.reloadData()
    }
    
    /**
     * #mark: CollectionView delegate, 經絡疏通重點
     * CollectionView, Cell width
     */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.bounds.size.width/3) - 15, height: 30)
    }

    /**
     * act Silder group, 次數改變
     */
    @IBAction func actSilderGroupt(sender: UISlider) {
        let strIdent = sender.restorationIdentifier
        
        if (strIdent == "sliderSugstHot") {
            labHot.text = String(Int(sender.value))
        }
        else if (strIdent == "sliderSugstSun") {
            labSun.text = String(Int(sender.value))
        }
    }
    
    /**
    * act button group, 確認送出
    */
    @IBAction func actgrpSubmit(sender: UIButton) {
        let strIdent = sender.restorationIdentifier
        let strKey = strIdent!.stringByReplacingOccurrencesOfString("submit", withString: "", range: nil)
        
        var strMsg = ""
        
        if (strIdent == "submitSugstEpower") {
            strMsg = getStrEpower()
        }
        else if (strIdent == "submitSugstHot") {
            strMsg = getStrHot()
        }
        else if (strIdent == "submitSugstSun") {
            strMsg = getStrSun()
        }
        else if (strIdent == "submitSugstEre") {
            strMsg = getStrEre()
        }
        
        delegate?.SubPageSubmitClick(strMsg, IdentName: strKey)
    }
    
    /**
    * 產生對應設備建議文字, E-Power
    */
    private func getStrEpower() -> String!{
        var strMsg = "[電能 E-power]\n"
        
        if (!swchEpower.on) {
            return ""
        }
        
        // segm0Epower, segm1Epower
        var aryTimeMsg = ["30分", "60分", "180分"]
        strMsg += "使用时间:" + aryTimeMsg[segm0Epower.selectedSegmentIndex] + ", "
        
        var aryGearMsg = ["一档", "二档", "三档"]
        strMsg += "使用档位:" + aryGearMsg[segm1Epower.selectedSegmentIndex]
        
        // collectionView 產生文字
        var strPointMsg = "\n经络疏通重点: "
        var isPointMsg = false
        
        for loopi in (0..<aryColviewBol.count) {
            if (aryColviewBol[loopi]) {
                strPointMsg += pubClass.getLang("bodypoint_" + String(loopi)) + " "
                isPointMsg = true
            }
        }
        
        if (isPointMsg) {
            strMsg += strPointMsg
        }
        
        return strMsg
    }
    
    /**
     * 產生對應設備建議文字, HotHouse
     */
    private func getStrHot() -> String!{
        var strMsg = "[远红外线仪]\n"
        
        if (!swchHot.on) {
            return ""
        }
        
        strMsg += "使用时间:"
        var aryTimeMsg = ["0分", "10分", "20分", "30分"]
        strMsg += "正面" + aryTimeMsg[segm0Hot.selectedSegmentIndex] + ", "
        strMsg += "背面" + aryTimeMsg[segm1Hot.selectedSegmentIndex] + ", "
        strMsg += labHot.text! + "次/天"
        
        return strMsg
    }
    
    /**
     * 產生對應設備建議文字, Sun
     */
    private func getStrSun() -> String!{
        var strMsg = "[摆动理疗仪]\n"
        
        if (!swchSun.on) {
            return ""
        }
        
        var aryTimeMsg = ["3分", "5分", "15分", "30分"]
        strMsg += "使用时间:" + aryTimeMsg[segm0Sun.selectedSegmentIndex] + ", "
        strMsg += labSun.text! + "次/天" + ", "
        strMsg += "姿势:" + edSun.text!
        
        return strMsg
    }
    
    /**
     * 產生對應設備建議文字, Ere
     */
    private func getStrEre() -> String!{
        var strMsg = "[活力能量仪]\n"
        
        if (!swchEre.on) {
            return ""
        }
        
        var aryTimeMsg = ["10分", "20分", "30分"]
        strMsg += "使用时间:" + aryTimeMsg[segm0Ere.selectedSegmentIndex] + ", "
        strMsg += "重点部位:" + edEre.text!
        
        return strMsg
    }
    
}