//
// 從手機取得圖片/照相，Image 取得/裁切/儲存
//

import UIKit
import Foundation

/**
 * 會員新增/編輯, 文字/圖片 資料儲存
 */
class MemberPict: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CutImageDelegate {
    
    // @IBOutlet
    @IBOutlet weak var imgTarget: UIImageView!
    
    // common property
    private var pubClass = PubClass()
    
    // parent 設定
    var strMemberID: String!
    
    // 檔案存取/圖片處理
    private var mImgPicker: UIImagePickerController!
    private var isNewPict = false
    private let sizeZoom: CGFloat = 3.0  // 图片缩放的最大倍数
    private let sizeCute: CGFloat = 120.0  // 裁剪框的長寬
    private let typeCut: Int = 1; // 裁剪框的形狀, 0=圓, 1=方
    
    // 其他
    private var bolReload = true
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 圖片處理相關
        mImgPicker = UIImagePickerController()
        mImgPicker.delegate = self
        mImgPicker.allowsEditing = false
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload == true) {
            bolReload = false
            
            // 取得原始圖片
            let imgURL = pubClass.D_WEBURL + "upload/HP_" + strMemberID + ".png"
            imgTarget.downloadImageFrom(link: imgURL, contentMode: UIViewContentMode.ScaleAspectFit)
        }
    }
    
    /**
     * #mark: UIImagePickerController Delegate
     * 圖片選取後，回傳圖片資料
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // 選擇圖片後，執行第三方圖片處理
        dismissViewControllerAnimated(true, completion: {
            ()->Void in
            
            let mCutImage: CutImage = CutImage()
            mCutImage.delegate = self
            mCutImage.scaleRation = self.sizeZoom
            mCutImage.clipType = self.typeCut
            mCutImage.radius = self.sizeCute
            mCutImage.initWithImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
            
            self.presentViewController(mCutImage, animated: true, completion: nil)
        })
    }
    
    /**
     * #mark: UIImagePickerController Delegate
     * 取消選取圖片
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: 自訂 Delegate, CutImageDelegate, 圖片裁切
     * 選擇的圖片裁切完成
     */
    func imageCutDone(vcCutImage: CutImage, FinishCutImage editImage: UIImage) {
        vcCutImage.dismissViewControllerAnimated(true, completion: {
            self.isNewPict = true
            self.imgTarget.image = editImage
        })
    }
    
    /**
     * Action, 點取進入圖片選取程序
     */
    @IBAction func actGallery(sender: UIBarButtonItem) {
        // 產生 UIImagePickerController, 選取圖片
        mImgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(mImgPicker, animated: true, completion:nil)
    }
    
    /**
     * Action, 點取 button '選擇相機
     */
    @IBAction func actCamera(sender: UIBarButtonItem) {
        if (UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil) {
            mImgPicker.sourceType = UIImagePickerControllerSourceType.Camera
            mImgPicker.cameraCaptureMode = .Photo
            presentViewController(mImgPicker, animated: true, completion: nil)
        } else {
            return
        }
    }
    
    /**
     * Action, 點取 '儲存'
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
    }
    
    /**
     * Action, 點取 '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}