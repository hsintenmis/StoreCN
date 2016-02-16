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
    
    @IBOutlet weak var swch01: UISwitch!
    @IBOutlet weak var swch02: UISegmentedControl!
    @IBOutlet weak var swch03: UISegmentedControl!
    
    @IBOutlet weak var swch11: UISegmentedControl!
    @IBOutlet weak var coltviewPoint: UICollectionView!
    
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var strToday = ""
    
    // collectionView 參數
    private var aryColviewBol: Array<Bool> = []
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        
        // collectionView 參數, 經絡疏通重點共 14 個，紀錄是否有被 '選取'
        for (var loopi = 0; loopi < 14; loopi++) {
            aryColviewBol.append(false)
        }
        
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        coltviewPoint.alpha = 0.0
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
        coltviewPoint.reloadData()
        coltviewPoint.alpha = 1.0
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
    * act button group, 確認送出
    */
    @IBAction func actgrpSubmit(sender: UIButton) {
        let strBtnIdent = sender.restorationIdentifier
        let strKey = strBtnIdent!.stringByReplacingOccurrencesOfString("submit", withString: "", range: nil)
        
        var strMsg = ""
        
        if (strBtnIdent == "submitSugstEpower") {
            strMsg = "\(swch01.selected)"
        }
        else if (strBtnIdent == "submitSugstHot") {
            strMsg = "\(swch11.selectedSegmentIndex)"
        }
        else if (strBtnIdent == "submitSugstSun") {
            strMsg = strKey
        }
        else if (strBtnIdent == "submitSugstEre") {
            strMsg = "number 4"
        }
        
        delegate?.SubPageSubmitClick(strMsg, IdentName: strKey)
    }
    
}