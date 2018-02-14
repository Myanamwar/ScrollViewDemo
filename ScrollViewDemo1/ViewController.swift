//
//  ViewController.swift
//  ScrollViewDemo1
//
//  Created by apple on 14/02/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    let photos:[String] = ["swift01", "swift02", "swift03", "swift04", "swift05", "swift06"]
    
    var pageImages:[UIImage] = [UIImage]()
    var pageViews:[UIView?] = [UIView]()
    var mainScrollView: UIScrollView!
    var pageScrollViews:[UIScrollView?] = [UIScrollView]()
    var currentPageView: UIView!
    var pageControl : UIPageControl = UIPageControl()
    let viewForZoomTag = 1
    var mainScrollViewContentSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mainScrollView = UIScrollView(frame: self.view.bounds)
        mainScrollView.isPagingEnabled = true
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        pageScrollViews = [UIScrollView?](repeating: nil, count: photos.count)
        let innerScrollFrame = mainScrollView.bounds
        
        mainScrollView.contentSize = CGSize(width: innerScrollFrame.origin.x + innerScrollFrame.size.width, height: mainScrollView.bounds.size.height)
        
        mainScrollView.backgroundColor = UIColor.white
        mainScrollView.delegate = self
        self.view.addSubview(mainScrollView)
        configScrollView()
        addPageControlOnScrollView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVisiblePages()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configScrollView() {
        
        self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width * CGFloat(photos.count), height: self.mainScrollView.frame.height)
        
        mainScrollViewContentSize = mainScrollView.contentSize
    }
    func addPageControlOnScrollView() {
        
        self.pageControl.numberOfPages = photos.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = UIColor.green
        
        pageControl.addTarget(self, action: #selector(changePage(sender:)), for: .valueChanged)
        self.pageControl.frame = CGRect(x: 0, y: self.view.frame.maxY - 44, width: self.view.frame.width, height: 44)
        
        self.view.addSubview(pageControl)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage(sender: AnyObject) -> () {
        
        let x = CGFloat(pageControl.currentPage) * mainScrollView.frame.size.width
        
        mainScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        loadVisiblePages()
        currentPageView = pageScrollViews[pageControl.currentPage]
    }
    func getViewAtPage(page: Int) -> UIView! {
        let image = UIImage(named: photos[page])
        let imageForZooming = UIImageView(image: image)
        var innerScrollFrame = mainScrollView.bounds
        
        if page < photos.count {
            innerScrollFrame.origin.x = innerScrollFrame.size.width * CGFloat(page)
        }
        
        imageForZooming.tag = viewForZoomTag
        
        let pageScrollView = UIScrollView(frame: innerScrollFrame)
        pageScrollView.contentSize = imageForZooming.bounds.size
        pageScrollView.delegate = self
        pageScrollView.showsVerticalScrollIndicator = false
        pageScrollView.showsHorizontalScrollIndicator = false
        pageScrollView.addSubview(imageForZooming)
        return pageScrollView
        
    }
    func setZoomScale(scrollView: UIScrollView) {
        
        let imageView = scrollView.viewWithTag(self.viewForZoomTag)
        let imageViewSize = imageView!.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    
    func loadVisiblePages() {
        let currentPage = pageControl.currentPage
        let previousPage =  currentPage > 0 ? currentPage - 1 : 0
        let nextPage = currentPage + 1 > pageControl.numberOfPages ? currentPage : currentPage + 1
        if currentPage == 0 {
            purgePage(page: 0)
            loadPage(page: 0)
        }
        for page in 0..<previousPage {
            purgePage(page: page)
        }
        
        for var page in 1..<pageControl.numberOfPages {
            page = page + 1
            purgePage(page: page)
        }
        if nextPage != pageControl.numberOfPages {
            
            for var page in (nextPage + 1)..<pageControl.numberOfPages {
                page = page + 1
                purgePage(page: page)
            }
        }
        for var page in previousPage..<nextPage {
            page = page + 1
            loadPage(page: page)
        }
        
    }
    func loadPage(page: Int) {
        if (page < 0) || (page >= pageControl.numberOfPages) {
            return
        }
        
        // 1
        if let pageScrollView = pageScrollViews[page] {
            setZoomScale(scrollView: pageScrollView)
            
        }
        else {
            let pageScrollView = getViewAtPage(page: page) as! UIScrollView
            setZoomScale(scrollView: pageScrollView)
            mainScrollView.addSubview(pageScrollView)
            pageScrollViews[page] = pageScrollView
        }
        
    }
    func purgePage(page: Int) {
        if page < 0 || page >= pageScrollViews.count {
            return
        }
        if let pageView = pageScrollViews[page] {
            pageView.removeFromSuperview()
            pageScrollViews[page] = nil
        }
    }
    
    func centerScrollViewContents(scrollView: UIScrollView) {
        let imageView = scrollView.viewWithTag(self.viewForZoomTag)
        let imageViewSize = imageView!.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageViewSize.height) / 2 : 0
        
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents(scrollView: scrollView)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.viewWithTag(viewForZoomTag)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let targetOffset = targetContentOffset.pointee.x
        let zoomRatio = scrollView.contentSize.height / mainScrollViewContentSize.height
        
        if zoomRatio == 1 {
            let mainScrollViewWidthPerPage = mainScrollViewContentSize.width / CGFloat(pageControl.numberOfPages)
            
            let currentPage = targetOffset / (mainScrollViewWidthPerPage * zoomRatio)
            pageControl.currentPage = Int(currentPage)
            loadVisiblePages()
        }
        else {
            
            let mainScrollViewWidthPerPage = mainScrollViewContentSize.width / CGFloat(pageControl.numberOfPages)
            //            let currentPage = targetOffset / (mainScrollViewWidthPerPage * zoomRatio)
        }
    }
}

