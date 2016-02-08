//
// PageViewController
//

import Foundation
import UIKit

/**
 * protocol, PagerView 相關
 */
protocol MemberMainPagerDelegate {
    // page 滑動完成
    func PageTransFinish(position: Int)
}

/**
 * 會員主選單下的 資料列表, 使用 pager
 */
class MemberMainPager: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var delegateMemberMainPager = MemberMainPagerDelegate?()
    
    // 各個 pager 對應的代碼, parent 設定, 對應 'aryVCIdent'
    // 參考上層 ["course", "mead", "soqibed", "purchase", "health"]
    var aryMenuName: Array<String>!
    
    // 各個 Pager Table 需要的 datasource, parent 設定
    var dictAllData: Dictionary<String, AnyObject>!
    
    // Pager 包含的 sub VC
    private let aryVCIdent = ["CourseList", "MeadList","SoqibedList","PurchaseList","Health"]  // Storyboard Identname
    
    private var aryPages: Array<UIViewController>!  // 全部 page 的 array
    private var indexPages = -1;  // 目前已滑動完成 page 的 position
    private var indexNextPages = 1;
    
    // View DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        self.makePages()
        
        // 初始與顯示第一個頁面
        self.moveToPage(0)
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /**
     * 產生各個 page 頁面，加到 'aryPages'
     */
    private func makePages() {
        aryPages = []
        //let vcEmpty = storyboard?.instantiateViewControllerWithIdentifier("NodataView")
        
        // 各個 page 加入 aryPages
        for (var i=0; i<aryMenuName.count; i++) {
            let strMenuName = aryMenuName[i]
            
            switch (strMenuName) {
                
            case "course":  // 療程資料 VC
                let mVC: PubCourseSelect = storyboard?.instantiateViewControllerWithIdentifier("PubCourseSelect") as! PubCourseSelect
                
                if let tmpDict = dictAllData["course"] as? Array<Dictionary<String, AnyObject>> {
                    mVC.aryCourseData = tmpDict
                }
                
                aryPages.append(mVC)
                
                break
                
            case "mead":  // Mead 資料 VC
                let mVC: PubMeadDataSelect = storyboard?.instantiateViewControllerWithIdentifier("PubMeadDataList") as! PubMeadDataSelect
                
                if let tmpDict = dictAllData["mead"] as? Array<Dictionary<String, AnyObject>> {
                    mVC.aryMeadData = tmpDict
                }
                
                aryPages.append(mVC)
                
                break
                
            case "soqibed":  // SoqiBed 資料 VC
                let mVC: PubSoqibedSelect = storyboard?.instantiateViewControllerWithIdentifier("PubSoqibedSelect") as! PubSoqibedSelect
                
                if let tmpDict = dictAllData["soqibed"] as? Array<Dictionary<String, AnyObject>> {
                    mVC.arySoqibedData = tmpDict
                }
                
                aryPages.append(mVC)
                
                break
                
            case "purchase":  // 會員購貨資料 VC
                let mVC: PubMemberPurchaseSelect = storyboard?.instantiateViewControllerWithIdentifier("PubMemberPurchaseSelect") as! PubMemberPurchaseSelect
                
                if let tmpDict = dictAllData["purchase"] as? Array<Dictionary<String, AnyObject>> {
                    mVC.aryPurchaseData = tmpDict
                }
                
                aryPages.append(mVC)
                
                break
                
            default:
                let mVC = storyboard?.instantiateViewControllerWithIdentifier("Member" + aryVCIdent[i])
                aryPages.append(mVC!)
            }
            
            
        }
    }
    
    /**
     * public
     * 根據代入的 position 滑動到指定的頁面
     */
    func moveToPage(position: Int) {
        var mDirect = UIPageViewControllerNavigationDirection.Forward
        
        if (indexPages > position) {
            mDirect = UIPageViewControllerNavigationDirection.Reverse
        }
        
        //let mDirect = (position == 0) ? UIPageViewControllerNavigationDirection.Reverse : UIPageViewControllerNavigationDirection.Forward
        
        setViewControllers([aryPages[position]], direction: mDirect, animated: true, completion: nil)
        indexPages = position
    }
    
    /**
     * #mark: UIPageViewController delegate
     * page 前一個頁面
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = aryPages.indexOf(viewController)!
        
        //let previousIndex = abs((currentIndex - 1) % pages.count)
        let previousIndex = (currentIndex - 1)
        indexPages = previousIndex
        
        if (previousIndex < 0) {
            indexPages = 0
            return nil
        }
        
        return aryPages[previousIndex]
    }
    
    /**
    * #mark: UIPageViewController delegate
    * page 下個頁面
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = aryPages.indexOf(viewController)!
        
        //let nextIndex = abs((currentIndex + 1) % pages.count)
        let nextIndex = currentIndex + 1
        indexPages = nextIndex
        
        if (nextIndex == aryPages.count) {
            indexPages = currentIndex
            return nil
        }
        
        return aryPages[nextIndex]
    }
    
    /**
     * #mark: UIPageViewController delegate
     * page 總頁數
     */
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (aryPages.count == 5) ? 0 : aryPages.count
    }
    
    /**
     * #mark: UIPageViewController delegate
     * 回傳選擇頁面的 position
     */
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.indexPages
    }
    
    /**
     * #mark: UIPageViewController delegate
     * Called after a gesture-driven transition completes.
     * 滑動完成時
     */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // 滑動完成時, 取得目前頁面 position
        if(completed){
            self.indexPages = self.indexNextPages;
            
            // parent class 執行相關程序
            delegateMemberMainPager?.PageTransFinish(self.indexPages)
            
            return
        }
        
        self.indexNextPages = 0;
    }
    
    /**
     * #mark: UIPageViewController delegate
     * Called before a gesture-driven transition begins.
     * 滑動開始時
     */
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        let controller = pendingViewControllers.first
        self.indexNextPages = aryPages.indexOf(controller!)!
    }

}