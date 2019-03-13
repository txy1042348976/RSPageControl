//
//  RSCycleScrollView.swift
//  RSPageControl
//
//  Created by yuxiit on 2019/3/12.
//  Copyright © 2019 yuxiit. All rights reserved.
//

import UIKit
import Kingfisher

/// Style
public enum PageControlStyle {
    case none
    case system
    case snake

}

/// LLCycleScrollViewDelegate
@objc public protocol RSCycleScrollViewDelegate: class {
    @objc func cycleScrollView(_ cycleScrollView: RSCycleScrollView, didSelectItemIndex index: NSInteger)
    @objc optional func cycleScrollView(_ cycleScrollView: RSCycleScrollView, scrollTo index: NSInteger)
}



open class RSCycleScrollView: UIView {

    /// 计时器
    fileprivate var dtimer: DispatchSourceTimer?
    /// 容器组件 UICollectionView
    fileprivate var collectionView: UICollectionView!
    
    // Identifier
    fileprivate let identifier = "RSCycleScrollViewCell"
    
    /// UICollectionViewFlowLayout
    lazy fileprivate var flowLayout: UICollectionViewFlowLayout? = {
        let tempFlowLayout = UICollectionViewFlowLayout.init()
        tempFlowLayout.minimumLineSpacing = 0
        tempFlowLayout.scrollDirection = .horizontal
        return tempFlowLayout
    }()
    
    // MARK: PageControl
    /// 注意： 由于属性较多，所以请使用style对应的属性，如果没有标明则通用
    /// PageControl
    open var pageControl: UIPageControl?
    
    
    /// Tint Color
    open var pageControlTintColor: UIColor = UIColor.lightGray {
        didSet {
            setupPageControl()
        }
    }
    // InActive Color
    open var pageControlCurrentPageColor: UIColor = UIColor.white {
        didSet {
            setupPageControl()
        }
    }
    
    // MARK: CustomPageControl
    /// Custom PageControl
    open var customPageControl: UIView?
    
    /// Style [.fill, .pill, .snake]
    open var customPageControlStyle: PageControlStyle = .system {
        didSet {
            setupPageControl()
        }
    }
    
    /// Tint Color
    open var customPageControlTintColor: UIColor = UIColor.white {
        didSet {
            setupPageControl()
        }
    }
    /// Indicator Padding
    open var customPageControlIndicatorPadding: CGFloat = 3 {
        didSet {
            setupPageControl()
        }
    }
    
    /// Radius [PageControlStyle == .fill]
    open var FillPageControlIndicatorRadius: CGFloat = 4 {
        didSet {
            setupPageControl()
        }
    }
    
    /// Active Tint Color [PageControlStyle == .pill || PageControlStyle == .snake]
    open var customPageControlInActiveTintColor: UIColor = UIColor(white: 1, alpha: 0.3) {
        didSet {
            setupPageControl()
        }
    }

    
    /// Init
    ///
    /// - Parameter frame: CGRect
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupMainView()
    }
    
    /// Init
    ///
    /// - Parameter aDecoder: NSCoder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMainView()
    }
    
    

    /// 协议
    open weak var delegate: RSCycleScrollViewDelegate?
 
    
    /// 开启/关闭URL特殊字符处理
    open var isAddingPercentEncodingForURLString: Bool = false

    /// Collection滚动方向
    fileprivate var position: UICollectionView.ScrollPosition! = .centeredHorizontally
    
    open var imagePaths: Array<String> = [] {
        didSet {
            totalItemsCount = infiniteLoop ? imagePaths.count * 100 : imagePaths.count
            if imagePaths.count > 1 {
                collectionView.isScrollEnabled = true
                if autoScroll {
                    setupTimer()
                }
            }else{
                collectionView.isScrollEnabled = false
                invalidateTimer()
            }

            collectionView.reloadData()

            setupPageControl()
        }
    }
    /// 滚动间隔时间,默认2秒
    open var autoScrollTimeInterval: Double = 2.0 {
        didSet {
            autoScroll = true
        }
    }
    
    // MARK:- Config
    /// 自动轮播- 默认true
    open var autoScroll: Bool = true {
        didSet {
            invalidateTimer()
            // 如果关闭的无限循环，则不进行计时器的操作，否则每次滚动到最后一张就不在进行了。
            if autoScroll && infiniteLoop {
                setupTimer()
            }
        }
    }
    
    /// 无限循环- 默认true，此属性修改了就不存在轮播的意义了
    open var infiniteLoop: Bool = true {
        didSet {
            if imagePaths.count > 0 {
                let temp = imagePaths
                imagePaths = temp
            }
        }
    }
    
    
    // MARK:- Private
    /// 总数量
    fileprivate var totalItemsCount: NSInteger! = 1

    /// 最大伸展空间(防止出现问题，可外部设置)
    /// 用于反方向滑动的时候，需要知道最大的contentSize
    fileprivate var maxSwipeSize: CGFloat = 0
    
    
    /// 滚动方向，默认horizontal
    open var scrollDirection: UICollectionView.ScrollDirection? = .horizontal {
        didSet {
            flowLayout?.scrollDirection = scrollDirection!
            if scrollDirection == .horizontal {
                position = .centeredHorizontally
            }else{
                position = .centeredVertically
            }
        }
    }
    
    
    
}


// MARK: UIViewHierarchy | LayoutSubviews
extension RSCycleScrollView {

    // MARK: layoutSubviews
    override open func layoutSubviews() {
        super.layoutSubviews()
        // CollectionView
        collectionView.frame = self.bounds
        
        
        // 计算最大扩展区大小
        if scrollDirection == .horizontal {
            maxSwipeSize = CGFloat(imagePaths.count) * collectionView.frame.width
        }else{
            maxSwipeSize = CGFloat(imagePaths.count) * collectionView.frame.height
        }
        
        // Cell Size
        flowLayout?.itemSize = self.frame.size
        // Page Frame
        if customPageControlStyle == .none || customPageControlStyle == .system  {
            pageControl?.frame = CGRect.init(x: 0, y: self.rs_h-18, width: UIScreen.main.bounds.width, height: 5)
        } else {
            let y = self.rs_h-18
            let oldFrame = customPageControl?.frame
            customPageControl?.frame = CGRect.init(x: (oldFrame?.origin.x)!, y: y, width: (oldFrame?.size.width)!, height: 10)

        }

        if collectionView.contentOffset.x == 0 && totalItemsCount > 0 {
            var targetIndex = 0
            if infiniteLoop {
                targetIndex = totalItemsCount/2
            }
            collectionView.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: position, animated: false)
        }
    }
}



// MARK: 定时器模块
extension RSCycleScrollView {
    /// 添加Timer
    func setupTimer() {
        // 仅一张图不进行滚动操纵
        if self.imagePaths.count <= 1 { return }
        
        let l_dtimer = DispatchSource.makeTimerSource()
        l_dtimer.schedule(deadline: .now()+autoScrollTimeInterval, repeating: autoScrollTimeInterval)
        l_dtimer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.automaticScroll()
            }
        }
        // 继续
        l_dtimer.resume()
        dtimer = l_dtimer
    }
    
    
    /// 关闭倒计时
    func invalidateTimer() {
        dtimer?.cancel()
        dtimer = nil
    }
    
}

// MARK: UI
extension RSCycleScrollView {
    // MARK: 添加UICollectionView
    private func setupMainView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout!)
        collectionView.register(RSCycleScrollViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        self.addSubview(collectionView)
    }
    
    
    // MARK: 添加PageControl
    func setupPageControl() {
        
        // 重新添加
        if pageControl != nil {
            pageControl?.removeFromSuperview()
        }
        
        if customPageControl != nil {
            customPageControl?.removeFromSuperview()
        }
        
        if imagePaths.count <= 1 {
            return
        }
        
        if customPageControlStyle == .none {
            pageControl = UIPageControl.init()
            pageControl?.numberOfPages = self.imagePaths.count
        }
        
        if customPageControlStyle == .system {
            pageControl = UIPageControl.init()
            pageControl?.pageIndicatorTintColor = pageControlTintColor
            pageControl?.currentPageIndicatorTintColor = pageControlCurrentPageColor
            pageControl?.numberOfPages = self.imagePaths.count
            self.addSubview(pageControl!)
            pageControl?.isHidden = false
        }

        
        if customPageControlStyle == .snake {
            customPageControl = RSSnakePageControl.init(frame: CGRect.zero)
            (customPageControl as! RSSnakePageControl).activeTint = customPageControlTintColor
            (customPageControl as! RSSnakePageControl).indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as! RSSnakePageControl).indicatorRadius = FillPageControlIndicatorRadius
            (customPageControl as! RSSnakePageControl).inactiveTint = customPageControlInActiveTintColor
            (customPageControl as! RSSnakePageControl).pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }
        
      
        calcScrollViewToScroll(collectionView)
    }
    
    
}

// MARK:- collectionView代理数据源
extension RSCycleScrollView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount == 0 ? 1:totalItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RSCycleScrollViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RSCycleScrollViewCell

            
            // 0==count 占位图
            if imagePaths.count == 0 {
                cell.bannerImage.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
            }else{
                let itemIndex = pageControlIndexWithCurrentCellIndex(index: indexPath.item)
                let imagePath = imagePaths[itemIndex]
        
                // 根据imagePath，来判断是网络图片还是本地图
                if imagePath.hasPrefix("http") {
                    let escapedString = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    cell.bannerImage.kf.setImage(with: URL(string: isAddingPercentEncodingForURLString ? escapedString ?? imagePath : imagePath), placeholder: nil)
                }else{
                    if let image = UIImage.init(named: imagePath) {
                        cell.bannerImage.image = image;
                    }else{
                        cell.bannerImage.image = UIImage.init(contentsOfFile: imagePath)
                    }
                }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.cycleScrollView(self, didSelectItemIndex: pageControlIndexWithCurrentCellIndex(index: indexPath.item))
        }
    }
    
//    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//
//        if let didSelectItemAtIndexPath = lldidSelectItemAtIndex {
//            didSelectItemAtIndexPath(pageControlIndexWithCurrentCellIndex(index: indexPath.item))
//        }else if let delegate = delegate {
//            delegate.cycleScrollView(self, didSelectItemIndex: pageControlIndexWithCurrentCellIndex(index: indexPath.item))
//        }
//    }
    
    
}


// MARK: UIScrollViewDelegate
extension RSCycleScrollView: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imagePaths.count == 0 { return }
        calcScrollViewToScroll(scrollView)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScroll {
            invalidateTimer()
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if imagePaths.count == 0 { return }
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        
        // 滚动后的回调协议
        delegate?.cycleScrollView?(self, scrollTo: indexOnPageControl)
        
        if autoScroll {
            setupTimer()
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if imagePaths.count == 0 { return }
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        
        // 滚动后的回调协议
        delegate?.cycleScrollView?(self, scrollTo: indexOnPageControl)
        
        if dtimer == nil && autoScroll {
            setupTimer()
        }
    }
    
    fileprivate func calcScrollViewToScroll(_ scrollView: UIScrollView) {
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        if customPageControlStyle == .none || customPageControlStyle == .system  {
            pageControl?.currentPage = indexOnPageControl
        }else{
            var progress: CGFloat = 999
            // Direction
            if scrollDirection == .horizontal {
                var currentOffsetX = scrollView.contentOffset.x - (CGFloat(totalItemsCount) * scrollView.frame.size.width) / 2
                if currentOffsetX < 0 {
                    if currentOffsetX >= -scrollView.frame.size.width{
                        currentOffsetX = CGFloat(indexOnPageControl) * scrollView.frame.size.width
                    }else if currentOffsetX <= -maxSwipeSize{
                        collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                    }else{
                        currentOffsetX = maxSwipeSize + currentOffsetX
                    }
                }
                if currentOffsetX >= CGFloat(self.imagePaths.count) * scrollView.frame.size.width && infiniteLoop{
                    collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                }
                progress = currentOffsetX / scrollView.frame.size.width
            }else if scrollDirection == .vertical{
                var currentOffsetY = scrollView.contentOffset.y - (CGFloat(totalItemsCount) * scrollView.frame.size.height) / 2
                if currentOffsetY < 0 {
                    if currentOffsetY >= -scrollView.frame.size.height{
                        currentOffsetY = CGFloat(indexOnPageControl) * scrollView.frame.size.height
                    }else if currentOffsetY <= -maxSwipeSize{
                        collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                    }else{
                        currentOffsetY = maxSwipeSize + currentOffsetY
                    }
                }
                if currentOffsetY >= CGFloat(self.imagePaths.count) * scrollView.frame.size.height && infiniteLoop{
                    collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                }
                progress = currentOffsetY / scrollView.frame.size.height
            }
            
            if progress == 999 {
                progress = CGFloat(indexOnPageControl)
            }
            // progress
            if customPageControlStyle == .snake {
                (customPageControl as? RSSnakePageControl)?.progress = progress
            }
        }
    }
}




// MARK:- Events
extension RSCycleScrollView {
    /// 自动轮播
    @objc func automaticScroll() {
        if totalItemsCount == 0 {return}
        let targetIndex = currentIndex() + 1
        scollToIndex(targetIndex: targetIndex)
    }
    
    
    /// 滚动到指定位置
    ///
    /// - Parameter targetIndex: 下标-Index
    func scollToIndex(targetIndex: Int) {
        if targetIndex >= totalItemsCount {
            if infiniteLoop {
                collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
            }
            return
        }
        collectionView.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: position, animated: true)
    }
    
    /// 当前位置
    ///
    /// - Returns: 下标-Index
    func currentIndex() -> NSInteger {
        if collectionView.rs_w == 0 || collectionView.rs_h == 0 {
            return 0
        }
        var index = 0
        if flowLayout?.scrollDirection == UICollectionView.ScrollDirection.horizontal {
            index = NSInteger(collectionView.contentOffset.x + (flowLayout?.itemSize.width)! * 0.5)/NSInteger((flowLayout?.itemSize.width)!)
        }else {
            index = NSInteger(collectionView.contentOffset.y + (flowLayout?.itemSize.height)! * 0.5)/NSInteger((flowLayout?.itemSize.height)!)
        }
        return index
    }
    
    /// PageControl当前下标对应的Cell位置
    ///
    /// - Parameter index: PageControl Index
    /// - Returns: Cell Index
    func pageControlIndexWithCurrentCellIndex(index: NSInteger) -> (Int) {
        return imagePaths.count == 0 ? 0 : Int(index % imagePaths.count)
    }
    
}


// MARK:- cell
class RSCycleScrollViewCell: UICollectionViewCell {
     var bannerImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup ImageView
    fileprivate func setupImageView() {
        bannerImage = UIImageView.init()
        // 默认模式
        //        imageView.contentMode = .scaleAspectFill
        
        bannerImage.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
//        bannerImage.clipsToBounds = true
//        bannerImage.layer.cornerRadius = 5
        self.contentView.addSubview(bannerImage)
        
    }
    
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bannerImage.frame = CGRect(x: 0, y: 0, width: self.rs_w, height: self.rs_h)
    }
    
    
    
}


// MARK:- RSSnakePageControl
open class RSSnakePageControl: UIView {
    
    // MARK: - PageControl
    
    open var pageCount: Int = 0 {
        didSet {
            updateNumberOfPages(pageCount)
        }
    }
    open var progress: CGFloat = 0 {
        didSet {
            layoutActivePageIndicator(progress)
        }
    }
    open var currentPage: Int {
        return Int(round(progress))
    }
    
    
    // MARK: - Appearance
    
    open var activeTint: UIColor = UIColor.white {
        didSet {
            activeLayer.backgroundColor = activeTint.cgColor
        }
    }
    open var inactiveTint: UIColor = UIColor(white: 1, alpha: 0.3) {
        didSet {
            inactiveLayers.forEach() { $0.backgroundColor = inactiveTint.cgColor }
        }
    }
    open var indicatorPadding: CGFloat = 10 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }
    open var indicatorRadius: CGFloat = 5 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }
    
    fileprivate var indicatorDiameter: CGFloat {
        return indicatorRadius * 2
    }
    fileprivate var inactiveLayers = [CALayer]()
    fileprivate lazy var activeLayer: CALayer = { [unowned self] in
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPoint.zero,
                             size: CGSize(width: self.indicatorDiameter, height: self.indicatorDiameter))
        layer.backgroundColor = self.activeTint.cgColor
        layer.cornerRadius = self.indicatorRadius
        layer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()]
        return layer
        }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        pageCount = 0
        progress = 0
        indicatorPadding = 8
        indicatorRadius = 4
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - State Update
    
    fileprivate func updateNumberOfPages(_ count: Int) {
        // no need to update
        guard count != inactiveLayers.count else { return }
        // reset current layout
        inactiveLayers.forEach() { $0.removeFromSuperlayer() }
        inactiveLayers = [CALayer]()
        // add layers for new page count
        inactiveLayers = stride(from: 0, to:count, by:1).map() { _ in
            let layer = CALayer()
            layer.backgroundColor = self.inactiveTint.cgColor
            self.layer.addSublayer(layer)
            return layer
        }
        layoutInactivePageIndicators(inactiveLayers)
        // ensure active page indicator is on top
        self.layer.addSublayer(activeLayer)
        layoutActivePageIndicator(progress)
        self.invalidateIntrinsicContentSize()
    }
    
    
    // MARK: - Layout
    
    fileprivate func layoutActivePageIndicator(_ progress: CGFloat) {
        // ignore if progress is outside of page indicators' bounds
        guard progress >= 0 && progress <= CGFloat(pageCount - 1) else { return }
        let denormalizedProgress = progress * (indicatorDiameter + indicatorPadding)
        let distanceFromPage = abs(round(progress) - progress)
        var newFrame = activeLayer.frame
        let widthMultiplier = (1 + distanceFromPage*2)
        newFrame.origin.x = denormalizedProgress
        newFrame.size.width = newFrame.height * widthMultiplier
        activeLayer.frame = newFrame
    }
    
    fileprivate func layoutInactivePageIndicators(_ layers: [CALayer]) {
        let layerDiameter = indicatorRadius * 2
        var layerFrame = CGRect(x: 0, y: 0, width: layerDiameter, height: layerDiameter)
        layers.forEach() { layer in
            layer.cornerRadius = self.indicatorRadius
            layer.frame = layerFrame
            layerFrame.origin.x += layerDiameter + indicatorPadding
        }
        // 布局
        let oldFrame = self.frame
        let width = CGFloat(inactiveLayers.count) * indicatorDiameter + CGFloat(inactiveLayers.count - 1) * indicatorPadding
        self.frame = CGRect.init(x: UIScreen.main.bounds.width / 2 - width / 2, y: oldFrame.origin.y, width: width, height: oldFrame.size.height)
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactiveLayers.count) * indicatorDiameter + CGFloat(inactiveLayers.count - 1) * indicatorPadding,
                      height: indicatorDiameter)
    }
}






// MARK:- Frame
extension UIView {
    public var rs_x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(value) {
            self.frame = CGRect(x: value, y: self.rs_y, width: self.rs_w, height: self.rs_h)
        }
    }
    
    public var rs_y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set(value) {
            self.frame = CGRect(x: self.rs_x, y: value, width: self.rs_w, height: self.rs_h)
        }
    }
    
    public var rs_w: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.rs_x, y: self.rs_y, width: value, height: self.rs_h)
        }
    }
    
    public var rs_h: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.rs_x, y: self.rs_y, width: self.rs_w, height: value)
        }
    }
}


