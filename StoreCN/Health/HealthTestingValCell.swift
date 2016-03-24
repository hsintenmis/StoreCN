//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 健康管理日曆, TableView Cell, 各個健康項目的數值 Cell
 */
class HealthTestingValCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labStatu: UILabel!
    @IBOutlet weak var labMsg: UILabel!
    @IBOutlet weak var labVal: UILabel!
    @IBOutlet weak var labUnit: UILabel!
    
    // 其他參數
    private var pubClass: PubClass!
    private var mHealthExplainTestData: HealthExplainTestData!  // 數值解釋說明
    
    // field 相關 圖片與文字顏色值設定
    private let dictColor = ["normal":"303030", "none":"c0c0c0", "good":"3366CC", "bad":"FF6666"]
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, mPubClass: PubClass!, strField: String!) {
        
        // 參數設定
        pubClass = mPubClass
        
        mHealthExplainTestData = HealthExplainTestData()
        
        // 設定當日的年齡性別
        if (ditItem["age"] != nil) {
            mHealthExplainTestData.SetUserData(Int(ditItem["age"] as! String)!, gender: ditItem["gender"] as! String)
        }
        
        // filed 設定
        labName.text = ditItem["name"] as? String
        labVal.text = ditItem["val"] as? String
        labUnit.text = ditItem["unit"] as? String
        
        // 產生數值解釋文字資料
        self.setExplainData(strField, dictData: ditItem as! Dictionary<String, String>)
    }
    
    /**
     * 指定健康項目，數值解釋文字設定
     * ex. ["group": "bmi", "field": "bmi", "unit": "", "val": "0.0", "name": "BMI"]<BR>
     * 回傳如:
     * 'stat', ex. 正常, 腰臀比超標 ....<BR>
     * 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
     * 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
     * 'result', 'good'正常, 'bad'不正常, 'none'無數值, 可以給'圖片使用'
     */
    private func setExplainData(strField: String!, dictData: Dictionary<String, String>) {
        let newCellData = mHealthExplainTestData.GetTestExplain(strField, jobjItem: dictData)
        let strResult = newCellData["result"]!
        let dbVal = Double(dictData["val"]!)!
        
        // 顏色預設值
        labName.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        labStatu.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        labVal.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        labUnit.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        
        // 沒有數值（數值 = 0）
        if ( dbVal == 0.0 ) {
            labName.textColor = pubClass.ColorHEX(dictColor["none"]!)
            labStatu.textColor = pubClass.ColorHEX(dictColor["none"]!)
            labVal.textColor = pubClass.ColorHEX(dictColor["none"]!)
            labUnit.textColor = pubClass.ColorHEX(dictColor["none"]!)
            
            labStatu.text = pubClass.getLang("health_nodata")
            labMsg.text = ""
            
            return
        }
        
        // 有數值 沒有說明
        if ( dbVal > 0.0 && strResult == "none") {
            labStatu.text = pubClass.getLang("health_noexplain")
            labMsg.text = ""
            
            return
        }
        
        // 有說明
        labStatu.text = newCellData["stat"]
        labMsg.text = pubClass.getLang("healthstandvalexplain") + "\n" + newCellData["explain"]!
        
        if (strResult == "good" || strResult == "bad") {
            labName.textColor = pubClass.ColorHEX(dictColor[strResult]!)
            labStatu.textColor = pubClass.ColorHEX(dictColor[strResult]!)
            labVal.textColor = pubClass.ColorHEX(dictColor[strResult]!)
            labUnit.textColor = pubClass.ColorHEX(dictColor[strResult]!)
        }
        
        // 特殊項目腰臀比，顯示腰圍臀圍數值
        if (dictData["field"] == "whr" && newCellData["stat_ext"] != nil) {
            labStatu.text = newCellData["stat"]! + "\n" + newCellData["stat_ext"]!
        }
        
        return
    }
    
}