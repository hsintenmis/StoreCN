//
// 藍牙 BLE 必填標準參數 (iOS不用處理)
// 關閉或打開通知(Notify)的UUID, 藍牙規格固定值
// NOTIFY = "00002902-0000-1000-8000-00805f9b34fb" (Descriptor)
//

import UIKit
import CoreBluetooth
import Foundation

/**
 * 藍牙4.0 BLE BluetoothLeService
 * <P>
 * 廠商: ACCUWAY, 型號:BT908<BR>
 * GATT service : f433bd80-75b8-11e2-97d9-0002a5d5c51b
 * D_DEVNAME = "VScale"
 * <P>
 * Characteristics定義<BR>
 * Name: Calculate Result, 輸入數值計算結果<BR>
 * 計算體脂肪, 水分, water, muscle, bone, etc. Assigned Number:
 * 29f11080-75b9-11e2-8bf6-0002a5d5c51b Properties: writeWithResponse
 *
 * Name: Test Result Description: Read or notify the test result Assigned
 * Number: 1a2ea400-75b9-11e2-be05-0002a5d5c51b Properties: Read/Nofity
 * <P>
 *
 * 傳入BT資料, 身高,年齡,性別(M=0, F=1),如下:<BR>
 * 10 01 00 1E AF => 數據類型(固定)10, 用户：01, 性别：00, 年龄：2D(45), 身高：AD(173)
 * <P>
 *
 * 傳回數據如下：(最後一碼為'操作类型',不使用),<BR>
 * 01H 0XH 模式 + 第幾個 user XXH(性别） XXH(年龄） XXH（身高） XXH XXH(重量值，两个字节）+
 * 脂肪（两个字节）+水分（两个字节）+骨骼（两个字节）+肌肉（两个字节）+ 内脏脂肪（一个字节）+卡路里（两个字节）+BMI（两个字节）。一共20个字节。
 * <P>
 * 未傳送資料，回傳如:<BR>
 * HEX: 00 00 00 00 02 AE FF FF FF FF FF FF FF FF FF FF FF FF FF 00<BR>
 * 傳入BT資料, 性別,年齡,身高，回傳如:<BR>
 * HEX: 01 00 23 A0 02 AE 00 E5 02 14 00 1F 01 29 0A 06 27 01 0B 00
 *
 * 判別何時傳給 BT 資料, 由接收的 BT 資料第一個 位元資料<BR>
 * '00' 表示需要傳給 BT 資料，'01'表示BT接收到傳入資料，經計算後再回傳全部的結果
 *
 * <p>
 * 本 class 回傳數值為 'Strings'
 */

 /**
 * protocol: BTScaleService Delegate
 */
protocol BTScaleServiceDelegate {
    /**
     * 回傳 parent 藍牙裝置狀態<BR>
     * @parm: identCode: 辨識碼<BR>
     * @parm: result, boolean<BR>
     * @parm: msgCode, 訊息
     * @parm: dictData, 體脂計回傳量測數值
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, dictData: Dictionary<String, String>?)
}

class BTScaleService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let IS_DEBUG = false
    
    // delegate
    var delegate = BTScaleServiceDelegate?()
    
    // 公用參數
    let aryTestingField: Array<String> = ["weight", "bmi", "fat", "water", "calory", "bone", "muscle", "vfat"]
    var BT_ISREADYFOTESTING = false  // 藍牙周邊是否可以開始使用
    
    // UID, 固定參數設定
    private let D_BTDEVNAME0 = "VScale"
    private let UID_SERV: CBUUID = CBUUID(string: "f433bd80-75b8-11e2-97d9-0002a5d5c51b")
    private let UID_CHAR_T: CBUUID = CBUUID(string: "1a2ea400-75b9-11e2-be05-0002a5d5c51b")
    private let UID_CHAR_W: CBUUID = CBUUID(string: "29f11080-75b9-11e2-8bf6-0002a5d5c51b")
    private let UID_NOTIFY: CBUUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    // BT service 相關參數
    private var mCentMgr: CBCentralManager! // BT CentralManager
    private var mConnDev: CBPeripheral?  // 已連線的藍牙周邊設備
    private var mUIDServ: CBService!
    private var mUIDChart_T: CBCharacteristic!
    private var mUIDChart_W: CBCharacteristic!
    
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
    * public, 設定 user 資料
    * @parm: dictData: 會員資料, 欄位: 'gender', 'age', 'height'
    */
    func setUserData(dictData: Dictionary<String, String>!) {
        dictUserData = dictData
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
        mUIDChart_T = nil
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
        if (peripheral.name == D_BTDEVNAME0) {
            self.mConnDev = peripheral
            self.mCentMgr.stopScan()
            self.mCentMgr.connectPeripheral(peripheral, options: nil)
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
            delegate?.handlerBLE("BT_statu", result: true, msg: pubClass.getLang(msg), dictData: nil)
        }
    }
    
    /**
    * #selector: 設置 Timer, 藍牙搜尋提停止
    */
    @objc private func procBTScanTimeOut() {
        if mCentMgr != nil {
            mCentMgr.stopScan()
        }
        
        // 連接不到裝置，顯示找不到裝置
        if (mConnDev == nil) {
            delegate?.handlerBLE("BT_statu", result: true, msg: pubClass.getLang("bt_cantfindbtdevice"), dictData: nil)
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
        peripheral.discoverCharacteristics([UID_CHAR_T, UID_CHAR_W], forService: self.mUIDServ)
    }
    
    /**
     * #mark: CBPeripheral Delegate
     * 指定的 Service channel, 查詢該 service 的 charccter
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // 指定的 UID Service channel, loop 該 service 的 Character
        for mChart in service.characteristics! {
            
            // Character = 'UID_CHAR_T'
            if (mChart.UUID == UID_CHAR_T) {
                self.mUIDChart_T = mChart
                
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
        self.mConnDev?.writeValue( NSData(bytes: [0x01] as [UInt8], length: 1), forCharacteristic: self.mUIDChart_T, type: CBCharacteristicWriteType.WithResponse)
        
        // 連接的 BT device, 讀寫通知更新開關已開啟，設備可以開始使用
        if (characteristic.isNotifying == true) {
            if (IS_DEBUG) { print("BT Device Notify OK!!") }
            
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
     * 若回傳第0個位元 = 0x00 (0), 表示 Scale 有測到體重資料，
     * 需要回傳 USER 資料(年齡/身高/性別)計算
     *
     * 傳送給體脂計的參數格式如:
     * 0x10 0x01 0x00 0x1E 0xAF =>
     *    數據類型(固定)10, 用户：01, 性别：00, 年龄：2D(45), 身高：AD(173)
     * byte[] byteVal = { 0x10, 0x01, gender, age, height };
     * byte[] byteVal = { 0x10, 0x01, 0x00, 0x2D, 0xAD };
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

        // 有資料
        if (characteristic.value?.length > 0) {
            if (IS_DEBUG) {print("chart update:\n\(characteristic.value!)")}

            // 取得回傳資料，格式如: HEX: 01 00 23 A0 02 ..., [Byte] = [UInt8]
            let mNSData = characteristic.value!
            var mIntVal = [UInt8](count:mNSData.length, repeatedValue:0)
            mNSData.getBytes(&mIntVal, length:mNSData.length)
            
            if (IS_DEBUG) { print("int val: \(mIntVal)") }
            
            // Scale 傳來的資料，第一個位元若為 0x00, 表示本機 BT 需要傳送 user 資料
            if (mIntVal[0] == 0) {
                //let mNSData = NSData(bytes: [UInt8]("A".utf8), length: 1)
                //let aryData: Array<UInt8> = [10, 1, 0, 45, 173]
                //let aryData: Array<UInt8> = [0x10, 0x01, 0x00, 0x2D, 0xAD]
                
                var aryData: Array<UInt8> = [0x10, 0x01];
                let intGender = (dictUserData["gender"] == "M") ? 0 : 1
                aryData.append(UInt8(intGender))
                aryData.append(UInt8(dictUserData["age"]!)!)
                aryData.append(UInt8(dictUserData["height"]!)!)
                
                let mNSData = NSData(bytes: &aryData, length: (aryData.count))
                
                if (IS_DEBUG) { print("tarin data to Dev:\n\(mNSData)") }
                
                // 資料寫入 'mUIDChart_W'
                peripheral.writeValue(mNSData, forCharacteristic: self.mUIDChart_W, type: CBCharacteristicWriteType.WithResponse)
                
                return
            }
            
            // 傳送 user 資料給 體重計計算後，體重計回傳結果
            if (mIntVal[0] == 1) {
                
                // 通知 parent 有資料回傳, 標記: 'BT_data'
                let dictRS = self.getScaleResult(mIntVal)
                let bolsRS = (Float(dictRS["weight"]!) > 0.0) ? true : false
                
                if (bolsRS == true) {
                    delegate?.handlerBLE("BT_data", result: true, msg: pubClass.getLang("bt_testing_success"), dictData: dictRS)
                } else {
                    delegate?.handlerBLE("BT_data", result: false, msg: pubClass.getLang("bt_testingvalerr"), dictData: dictRS)
                }
                
                return
            }
        }
    }
    
    /**
     * 解析體重計回傳數值, 欄位定義如下
     * ["weight", "bmi", "fat", "water", "calory", "bone", "muscle", "vfat"]
     * 傳入BT資料, 身高,年齡,性別，回傳如:<BR>
     * HEX: 01 00 23 A0 02 AE 00 E5 02 14 00 1F 01 29 0A 06 27 01 0B 00<BR>
     * -----00-01-02-03-04-05-06-07-08-09-10-11-12-13-14-15-16-17-18-19<BR>
     * --------ge-ag-hi-weigh--fat--water--bone-muscl-vf-calor--bmi--XX
     * [1, 1, 45, 173, 2, 177, 1, 23, 2, 1, 0, 28, 0, 221, 10, 6, 85, 0, 230, 0]
     * @return Dict data, ex. 'weight'='69.1', 'bmi'='23.0', ...
     */
    private func getScaleResult(aryRS: Array<UInt8>)-> Dictionary<String, String>! {
        // 預設數值
        var dictRS: Dictionary<String, String> = [:]
        for strScaleField in aryTestingField {
            dictRS[strScaleField] = "0.0"
        }
        dictRS["calory"] = "0"
        
        // 檢查回傳的資料是否太離譜, 以 'vfat'內臟脂肪判別 >= 99, <=1
        if (aryRS[14] >= 99 || aryRS[14] <= 1)  {
            print("vfat err")
            return dictRS
        }
        
        // 重新設定各健康數值
        dictRS["weight"] = tranHEX10(valHigh: aryRS[4], valLow: aryRS[5])
        dictRS["fat"] = tranHEX10(valHigh: aryRS[6], valLow: aryRS[7])
        dictRS["water"] = tranHEX10(valHigh: aryRS[8], valLow: aryRS[9])
        dictRS["bone"] = tranHEX10(valHigh: aryRS[10], valLow: aryRS[11])
        dictRS["muscle"] = tranHEX10(valHigh: aryRS[12], valLow: aryRS[13])
        dictRS["vfat"] = String(Int(aryRS[14]))
        dictRS["calory"] = String( Int(aryRS[15]) * 256 + Int(aryRS[16]) )
        dictRS["bmi"] = tranHEX10(valHigh: aryRS[17], valLow: aryRS[18])
        
        return dictRS
    }
    
    /**
     * 放大10倍資料轉換, weigh, fat, water, bone, muscle, bmi
     * HEX 數值為 02 AE, 實際的 val :'02AE' = 686, 已放大10倍<BR>
     * 需要 /10, 取小數點，本method直接用字元方式處理
     * <P>
     *
     * @param data0 : 高位 HEX 已轉成 int
     * @param data1 : 低位 HEX 已轉成 int
     * @return string
     */
    private func tranHEX10(valHigh data0: UInt8, valLow data1: UInt8)-> String {
        let strVal = String((Int(data0) * 256) + Int(data1))
        let numChar = strVal.characters.count
        let strFloatVal = pubClass.subStr(strVal, strFrom: (numChar - 1), strEnd: numChar)
        
        // 字元數目 <= 1, 表示為小數點數值
        if (numChar <= 1) {
            return "0." + strFloatVal
        }
        
        // 取得整數位數值
        let strDigInt = pubClass.subStr(strVal, strFrom: 0, strEnd: (numChar - 1))
        return strDigInt + "." + strFloatVal
    }
    
}