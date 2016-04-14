//
// 藍芽血壓計
// 藍牙預設 NOTIFY: "00002902-0000-1000-8000-00805f9b34fb" (Descriptor)
//

import CoreBluetooth
import Foundation

/**
 * protocol: BTBPService Delegate
 */
protocol BTBPServiceDelegate {
    /**
     * 回傳 parent 藍牙裝置狀態<BR>
     * @parm: identCode: 辨識碼<BR>
     * @parm: result, boolean<BR>
     * @parm: msgCode, 訊息
     * @parm: dictData, 藍芽設備回傳量測數值
     * @parm: intVal, 辨識碼詳細代碼
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, dictData: Dictionary<String, AnyObject>?)
}

/**
 * 藍芽血壓計
 *
 * 藍牙4.0 BLE BluetoothLeService
 * <P>
 * 廠商: 穩合, 型號: DA14580<BR>
 *
 * Device name: ClinkBlood
 * main Service UUID: FC00
 * Host  -> Slave (write)   UUID: FCA0
 * Slave -> Host  (notify)  UUID: FCA1
 * ? 0xFCA2       (write)
 *
 */
class BTBPService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let IS_DEBUG = true
    
    // protocol BTBPService Delegate
    var delegate: BTBPServiceDelegate?
    
    // public
    var BT_ISREADYFOTESTING = false  // 藍牙周邊是否可以開始使用
    
    // 藍芽裝置名稱
    private let aryBTNAME = ["ClinkBlood"]
    
    // UUID, Service, Char
    private let UID_SERV: CBUUID = CBUUID(string: "FC00")
    private let UID_CHAR_W: CBUUID = CBUUID(string: "FCA0")
    private let UID_CHAR_I: CBUUID = CBUUID(string: "FCA1")

    // BT service 相關參數
    private var mCentMgr: CBCentralManager! // BT CentralManager
    private var mConnDev: CBPeripheral?  // 已連線的藍牙周邊設備
    
    private var mUIDServ: CBService!
    private var mUIDChart_W: CBCharacteristic!
    private var mUIDChart_I: CBCharacteristic!
    
    // 其他參數
    private var pubClass = PubClass()
    private var dictUserData: Dictionary<String, String>!
    private var mTimer = NSTimer()
    
    /**
     * init
     */
    override init() {
        super.init()
    }
    
    /**
     * public parent 執行, BT 執行連接程序, 啟動 CBCentralManager
     */
    func BTConnStart() {
        if (BT_ISREADYFOTESTING != true) {
            mCentMgr = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    /**
     * public parent 執行, BT 斷開連接
     */
    func BTDisconn() {
        // 是否搜尋中
        if (mCentMgr != nil) {
            if (self.mCentMgr.isScanning) {
                if (IS_DEBUG) { print("BT is scanning and let it Stop!") }
                self.mCentMgr.stopScan()
            }
        }
        
        // BT dev 是否連線
        if (mConnDev != nil) {
            if (IS_DEBUG) { print("let BT dev cancel connect") }
            mCentMgr.cancelPeripheralConnection(mConnDev!)
        }
        
        mCentMgr = nil
        mConnDev = nil
        BT_ISREADYFOTESTING = false
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 開始探索 BLE 周邊裝置
     * On detecting a device, will get a call back to "didDiscoverPeripheral"
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if (IS_DEBUG) { print("Discovered: \(peripheral.name)") }
        
        // 找到指定裝置 名稱 or addr
        for strDevName in aryBTNAME {
            if (peripheral.name == strDevName) {
                self.mConnDev = peripheral
                self.mCentMgr.stopScan()
                self.mCentMgr.connectPeripheral(peripheral, options: nil)
                
                break
            }
        }
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 找到指定的Dev後，開始查詢與連接該Dev相關的 Service, Chart
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        if (IS_DEBUG) { print("\(peripheral.name): Start discover Device channel ...") }
        
        // 通知上層開始查詢藍牙設備 channel, 標記：'BT_statu', 顯示 '設備初始化訊息'
        delegate?.handlerBLE("BT_statu", result: true, msg: pubClass.getLang("bt_initing"), dictData: nil)
        
        // 開始執行 CBPeripheral Delegate 相關程序
        self.mConnDev?.delegate = self
        self.mConnDev?.discoverServices([UID_SERV])  // Dev 尋找指定 UID Service
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * CBCentralManager 斷線
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        if (IS_DEBUG) { print("CBCentralManager Disconnection!") }
        
        // 本 class 執行相關 BLE 中斷程序, 標記：'BT_conn'
        BTDisconn()
        delegate?.handlerBLE("BT_conn", result: false, msg: pubClass.getLang("bt_connect_break"), dictData: nil)
    }
    
    /**
     * #mark: CBCentralManager Delegate
     * 目前本機裝置 BLE 狀態
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        var msg = ""
        var bolRS = false
        
        switch (central.state) {
        case .PoweredOff:
            msg = "bt_mobile_off"
            
        case .PoweredOn:
            msg = "bt_mobile_on"
            bolRS = true
            
            // parent 顯示藍牙開啟搜尋周邊訊息
            delegate?.handlerBLE("BT_statu", result: true, msg: pubClass.getLang(msg), dictData: nil)
            
            // CBCentralManager 開始執行搜索藍牙 Device
            mCentMgr.scanForPeripheralsWithServices(nil, options: nil)
            
            // 設置 Timer
            mTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target:self, selector:#selector(self.procBTScanTimeOut), userInfo: nil, repeats: false)
            mTimer = NSTimer()
            
        case .Resetting:
            msg = "bt_mobile_resetting"
            
        case .Unauthorized:
            msg = "bt_mobile_unauthorized"
            
        case .Unknown:
            msg = "bt_mobile_unknown_stat"
            
        case .Unsupported:
            msg = "bt_mobile_unsupported"
        }
        
        if (IS_DEBUG) { print(msg) }
        
        // 設定 'handler', 標記：'BT_statu'
        if (bolRS != true) {
            var code = 2
            if (msg == "bt_mobile_off") {
                code = 3
            }
            
            delegate?.handlerBLE("BT_statu", result: true, msg: pubClass.getLang(msg), dictData: ["code":code])
        }
    }
    
    /**
     * #selector: 設置 Timer, 藍牙搜尋提停止
     */
    @objc private func procBTScanTimeOut() {
        if mCentMgr != nil {
            mCentMgr.stopScan()
        }
        
        // 連接不到裝置，顯示找不到裝置, 回傳 int 代碼 1
        if (mConnDev == nil) {
            delegate?.handlerBLE("BT_statu", result: true, msg: pubClass.getLang("bt_cantfindbtdevice"), dictData: ["code":1])
        }
    }
    
    /**
     * #mark: CBPeripheral Delegate
     * 已連接的 Dev, 查詢指定的 Service channel
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        // loop Device Service UUID, 設定藍芽設備主 service channel
        for tmpCBService in peripheral.services! {
            if (tmpCBService.UUID == UID_SERV) {
                self.mUIDServ = tmpCBService
                break
            }
        }
        
        if (IS_DEBUG) { print("found SrvChannel: \(self.mUIDServ.UUID)") }
        
        // 指定的 charact 執行 Discover 與連接
        peripheral.discoverCharacteristics([UID_CHAR_W, UID_CHAR_I], forService: self.mUIDServ)
    }
    
    /**
     * #mark: CBPeripheral Delegate
     * 指定的 Service channel, 查詢該 service 的 charccter
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // 指定的 UID Service channel, loop 該 service 的 Character
        for mChart in service.characteristics! {
            
            // Character = 'UID_CHAR_I'
            if (mChart.UUID == UID_CHAR_I) {
                self.mUIDChart_I = mChart
                
                // 直接執行關閉或打開通知 'Notify' 的 UUID, 藍牙規格固定值
                peripheral.setNotifyValue(true, forCharacteristic: mChart)
                
                if (IS_DEBUG) {print("start set notify:\(mChart.UUID)") }
            }
                // Character = 'UID_CHAR_W'
            else if (mChart.UUID == UID_CHAR_W) {
                self.mUIDChart_W = mChart
            }
        }
    }
    
    /**
     * #mark: CBPeripheral Delegate
     * NotificationStateForCharacteristic 更新
     */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("BT chart notify statu:")
            print("UID: \(characteristic.UUID)")
            print("Val: \(characteristic.value)")
            print("isNotifying: \(characteristic.isNotifying)\n")
        }
        
        // 連接的 BT device, 寫入讀寫更新通知 value
        self.mConnDev?.writeValue( NSData(bytes: [0x01] as [UInt8], length: 1), forCharacteristic: self.mUIDChart_I, type: CBCharacteristicWriteType.WithResponse)
        
        // 連接的 BT device, 讀寫通知更新開關已開啟，設備可以開始使用
        if (characteristic.isNotifying == true) {
            if (IS_DEBUG) {
                print("BT Device Notify OK!!")
            }
            
            // 通知上層可以開始使用藍芽設備, 設定 'handler', 標記：'BT_conn'
            delegate?.handlerBLE("BT_conn", result: true, msg: pubClass.getLang("bt_btdeviceready"), dictData: nil)
            
            BT_ISREADYFOTESTING = true
        }
    }
    
    /**
     * #mark: CBPeripheral Delegate
     * Dev 的 Characteristi 有資料變動通知
     *
     * BT 有資料更新，傳送到本機 BT 顯示
     *
     * 主 Service 數值回傳：血壓計回傳如下：
     *
     *  0  1   2   3   4   5   6   7   8   9   10  11   12  13  14  15  16 17 18 19
     * ----------------------------------------------------------------------------
     *            YY  MM  DD  HH  mm  ss      Val      Val  Ht
     * [0, 5, 12, 15, 08, 20, 21, 46, 18, 00, 125, 00, 077, 88, 255, 0, 0, 0, 0, 0]
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print(characteristic.value)
        // 有資料
        if (characteristic.value?.length > 0) {
            if (IS_DEBUG) {print("chart update:\n\(characteristic.value!)")}
            
            // 取得回傳資料，格式如: HEX: 01 00 23 A0 02 ..., [Byte] = [UInt8]
            let mNSData = characteristic.value!
            var mIntVal = [UInt8](count:mNSData.length, repeatedValue:0)
            mNSData.getBytes(&mIntVal, length:mNSData.length)
            
            if (IS_DEBUG) { print("int val: \(mIntVal)") }
            
            // parent handler
            let dictRS = self.getTestingResult(mIntVal)
            delegate?.handlerBLE("BT_data", result: true, msg: pubClass.getLang("bt_testing_success"), dictData: dictRS)
            
            return
        }
    }
    
    /**
     * 將血壓計傳回的 bit array 轉為可閱讀的 Dictionary<String, String>
     * 規格參考 'didUpdateValueForCharacteristic'
     */
    private func getTestingResult(aryRS: Array<UInt8>)-> Dictionary<String, String>! {
        var dictRS: Dictionary<String, String> = [:]
        dictRS["val_H"] = String(aryRS[10])
        dictRS["val_L"] = String(aryRS[12])
        dictRS["beat"] = String(aryRS[13])
        
        return dictRS
    }
    
    
}