//
// TableView Cell
//

import Foundation
import UIKit

class PubMemberSelectCell: UITableViewCell {

    @IBOutlet weak var imgPict: UIImageView!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labJoin: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labBirth: UILabel!
    
    private var pubClass = PubClass()
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!) {
        let strGender = pubClass.getLang("gender_" + (ditItem["gender"] as! String))
        let strAge = (ditItem["age"] as! String) + pubClass.getLang("name_age")
        let strId = ditItem["memberid"] as! String
        
        labId.text = strId
        labName.text = ditItem["membername"] as? String
        labGender.text = strGender + " " + strAge
        labTel.text = ditItem["tel"] as? String
        
        labJoin.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: "8s")
        labBirth.text = pubClass.formatDateWithStr(ditItem["birth"] as! String, type: "8s")
        
        // 圖片
        let imgURL = pubClass.D_WEBURL + "upload/HP_" + strId + ".png"
        imgPict.downloadImageFrom(link: imgURL, contentMode: UIViewContentMode.ScaleAspectFit)
    }
}