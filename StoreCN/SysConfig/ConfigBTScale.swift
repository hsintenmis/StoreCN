//
// with ContainerView, 藍牙周邊搜尋，點取指定設備取得 mac addr (iOS 不支援)
// 只能綁定 'identifier'
//
// 體脂計 dev name = 'VScale'
//

import UIKit
import Foundation
import CoreBluetooth

/**
 * protocol, ConfigBTScale Delegate
 */
protocol ConfigBTScaleDelegate {
    /**
     * 綁頂或解除 指定裝置後，上層藍牙 cell 資料需更新
     */
    func BTScaleBondChange(IdentID: String!)
}

/**
 * 設定 - 體脂計綁定
 */
class ConfigBTScale: UIViewController, CBCentralManagerDelegate {
    // 固定參數
    private let D_VSCALENAME = "VScale"
    
    // delegate
    var delegate = ConfigBTScaleDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var pubClass: PubClass!
    
    // table data source
    private var aryTableData: Array<CBPeripheral> = []
    
    // 藍牙 CBCentralManager 參數
    private var mBTCenter: CBCentralManager!  // BT mamager center
    private var currConnBTDev: CBPeripheral?  // 目前已連線的藍牙週邊設備
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // 本機藍牙啟動
        actBTCenter()
    }
    
    /**
    * 開始啟動藍牙 CBCentralManager
    */
    private func actBTCenter() {
        mBTCenter = CBCentralManager(delegate: self, queue: nil)
    }
    
    /**
     * 中斷目前本機 與 連線的藍芽週邊裝置
     */
    private func disconnBTDev() {
        if (currConnBTDev != nil) {
            mBTCenter.cancelPeripheralConnection(currConnBTDev!)
        }
    }
    
    /**
     * 開始執行搜索程序
     */
    private func scanBTDev() {
        mBTCenter.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 搜索藍牙週邊裝置
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // 取得設備資料, 檢查 dev的 'identifier' 有無重複, 加到 aryTableData
        if (peripheral.name == D_VSCALENAME) {
            let strIdent = peripheral.identifier
            var bolNeedAdd = true
            
            if (aryTableData.count > 0) {
                for tmpDev in aryTableData {
                    if (strIdent == tmpDev.identifier) {
                        bolNeedAdd = false
                        break
                    }
                }
            }
            
            if (bolNeedAdd == true) {
                aryTableData.append(peripheral)
                tableList.reloadData()
            }
        }
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 找到指定的BT, 開始查詢與連接 BT Service channel
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        currConnBTDev = peripheral
        
        // 彈出確認視窗，資料儲存並跳離
        let aryMsg = [pubClass.getLang("sysprompt"), pubClass.getLang("btsacel_bondmsg")]
        
        pubClass.popConfirm(self, aryMsg: aryMsg,
            withHandlerYes: {
                // 資料存入 'Prefer'
                let strID = peripheral.identifier.UUIDString
                let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
                mPref.setObject(strID, forKey: "vscale")
                
                // 斷開連線跳離本頁
                self.mBTCenter.stopScan()
                self.disconnBTDev()
                self.delegate?.BTScaleBondChange(strID)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            },
            withHandlerNo: {}
        )
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 目前 BLE center manage statu 改變，執行相關程序
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        var msg = ""
        var bolReady = false
        
        switch (central.state) {
        case .PoweredOff:
            msg = "本机蓝牙未开启!"
            
        case .PoweredOn:
            msg = "本机蓝牙已就绪"
            bolReady = true
            
        case .Resetting:
            msg = "本机蓝牙重新启动中..."
            
        case .Unauthorized:
            msg = "本机蓝牙未认证!"
            
        case .Unknown:
            msg = "本机蓝牙状态不明..."
            
        case .Unsupported:
            msg = "本机蓝牙不支援目前的系统平台..."
        }

        // 跳離或開始執行周邊搜索
        if (!bolReady) {
            pubClass.popIsee(self, Msg: msg, withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
        self.mBTCenter.stopScan()
        scanBTDev()
    }

    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, Cell 使用 Table Cell 預設的樣式
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 取得 Item data source, CellView
        let ditItem = aryTableData[indexPath.row]
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellConfigBTScale")!
        
        mCell.textLabel?.text = ditItem.name
        mCell.detailTextLabel?.text = ditItem.identifier.UUIDString
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 連結選擇的藍芽設備
        self.mBTCenter.stopScan()
        self.mBTCenter.connectPeripheral(aryTableData[indexPath.row], options: nil)
    }
    
    /**
     * act, '解除綁定'
     */
    @IBAction func actDisBond(sender: UIBarButtonItem) {
        let aryMsg = [pubClass.getLang("sysprompt"), pubClass.getLang("btsacel_disbondmsg")]
        
        pubClass.popConfirm(self, aryMsg: aryMsg,
            withHandlerYes: {
                // 資料存入 'Prefer'
                let strID = ""
                let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
                mPref.setObject(strID, forKey: "vscale")
                
                // 斷開連線跳離本頁
                self.mBTCenter.stopScan()
                self.disconnBTDev()
                self.delegate?.BTScaleBondChange(strID)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            },
            withHandlerNo: {}
        )
    }
    
    /**
    * act, 返回
    */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.mBTCenter.stopScan()
        self.disconnBTDev()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}