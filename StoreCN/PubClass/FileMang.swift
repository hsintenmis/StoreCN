//
// 行動裝置的 app 檔案管理 Add / Write / Read
// 僅適用於 app 目錄 'Documents'
//

import Foundation
import UIKit

/**
 * 檔案增刪修寫讀處理
 */
class FileMang {
    // 其他設定
    var isDebug = true;
    var mDocPath: String!  // 取得 documentsPath 路徑, 含'/'
    var aryAppPath: Array<String>!
    
    let mFileMgr = NSFileManager.defaultManager()
    
    /**
     * init
     */
    init() {
        aryAppPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        mDocPath = aryAppPath[0] + "/"
    }
    
    /**
     * 檔案/目錄 是否存在
     */
    func isFilePath(strFileName: String!) -> Bool{
        return self.mFileMgr.fileExistsAtPath(self.mDocPath + strFileName)
    }
    
    /**
     * 刪除 檔案/目錄
     */
    func delete(strFileName: String!) -> Bool{
        if (!isFilePath(strFileName)) {
            return false
        }
        
        do {
            try self.mFileMgr.removeItemAtPath(self.mDocPath + strFileName)
        }
        catch let error as NSError {
            if (isDebug) { print("err: delete failure!\n\(error)") }
            return false
        }
        
        return true
    }
    
    /**
     * 檔案寫資料 / 建立檔案 (String 寫入)
     *
     * @param strData : string or ""
     * @return Boolean
     */
    func createDir(strPath: String)->Bool {
        let mPath = mDocPath + strPath
        
        // 目錄已存在，return false
        if (self.isFilePath(mPath)) {
            if (isDebug) { print("err: directory exists: " + strPath) }
            return false
        }
        
        // 建立目錄程序
        do {
            try self.mFileMgr.createDirectoryAtPath(mPath, withIntermediateDirectories: false, attributes: nil)
            return true
        } catch let error as NSError {
            if (isDebug) { print("err: create directory failure!\n\(error)") }
            return false
        }
    }
    
    /**
     * 檔案寫資料 / 建立檔案 (String 寫入)
     *
     * @param strData : string or ""
     * @return Boolean
     */
    func write(strFileName: String!, strData: String)->Bool {
        let mFile = self.mDocPath + strFileName
        let mData = (strData.isEmpty) ? "" : strData
        let databuffer = mData.dataUsingEncoding(NSUTF8StringEncoding)
        
        return self.mFileMgr.createFileAtPath(mFile, contents: databuffer, attributes: nil)
    }
    
    /**
     * 檔案寫資料 / 建立檔案 (UIImage 寫入, jpeg)
     *
     * @param mImg : UIImage!
     * @return Boolean
     */
    func write(strFileName: String!, withUIImage mImg: UIImage!)->Bool {
        if let data = UIImageJPEGRepresentation(mImg, 0.7) {
            let mFile = self.mDocPath + strFileName
            return data.writeToFile(mFile, atomically: true)
        }
        
        return false
    }
    
    /**
     * 讀取檔案資料
     * @return: String or ""
     */
    func read(strFileName: String!) -> String {
        let mFile = self.mDocPath + strFileName
        if (!self.isFilePath(strFileName)) {
            if (isDebug) { print("err: file/path not exists!") }
            return ""
        }
        
        let mBuff = self.mFileMgr.contentsAtPath(mFile)
        if (mBuff == nil) {
            return ""
        }
        
        return String(data: mBuff!, encoding: NSUTF8StringEncoding)!
    }
    
    
    /**
     * 讀取檔案資料
     * @return: String or ""
     */
    func createDir(strName: String!)->Bool {
        let objDocPath = aryAppPath[0]
        let dataPath = objDocPath + "/" + strName
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            
            return true
        } catch let error as NSError {
            if (isDebug) { print(error.localizedDescription) }
            
            return false
        }
    }
    
    /**
     * 檔案或目錄更名
     */
    func rename(SourceName strSource: String, TargetName strTarget: String)->Bool {
        do {
            try mFileMgr.moveItemAtPath(strSource, toPath: strTarget)
            return true
        } catch let error as NSError {
            if (isDebug) { print(error.localizedDescription) }
            
            return false
        }
    }
    
}