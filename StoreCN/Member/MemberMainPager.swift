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
    
    // 各個 pager 對應的代碼, parent 設定
    var aryMenuName: Array<String>!
    
    // 各個 Pager Table 需要的 datasource, parent 設定
    var dictAllData: Dictionary<String, Array<Dictionary<String, AnyObject>>>!
    
    // Pager 包含的 sub VC
    private let aryVCIdent = ["CourseList", "MeadList","SoqibedList","PurchaseList","Health"]  // Storyboard Identname
    
    private var aryPages: Array<UIViewController> = []
    private var indexPages = 0;  // 目前已滑動完成 page 的 position
    private var indexNextPages = 1;
    
    // View DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        // 各個 page 加入 aryPages
        var mVC: UIViewController
 
        for strIdent in aryVCIdent {
            mVC = storyboard!.instantiateViewControllerWithIdentifier("Member" + strIdent)
            
            aryPages.append(mVC)
        }
        
        // 初始與顯示第一個頁面
        self.moveToPage(0)
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        print(dictAllData)
    }
    
    /**
     * public
     * 根據代入的 position 滑動到指定的頁面
     */
    func moveToPage(position: Int) {
        let mDirect = (position == 0) ? UIPageViewControllerNavigationDirection.Reverse : UIPageViewControllerNavigationDirection.Forward
        
        setViewControllers([aryPages[position]], direction: mDirect, animated: true, completion: nil)
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
        
        return (aryPages.count == 2) ? 0 : aryPages.count
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