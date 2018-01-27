//
//  PagingPicVC.swift
//  pics-ios
//
//  Created by Michael Skogberg on 26/12/2017.
//  Copyright © 2017 Michael Skogberg. All rights reserved.
//
import Foundation
import UIKit
import SnapKit

/// Swipe horizontally to show the next/previous image in the gallery.
/// Uses a UIPageViewController for paging.
class PicPagingVC: BaseVC {
    private let log = LoggerFactory.shared.vc(PicPagingVC.self)
    
    let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let pics: [Picture]
    private var index: Int
    let isPrivate: Bool
    let delegate: PicDelegate
    
    init(pics: [Picture], startIndex: Int, isPrivate: Bool, delegate: PicDelegate) {
        self.pics = pics
        self.index = startIndex
        self.isPrivate = isPrivate
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initUI() {
        navigationItem.title = "Pic"
        if isPrivate {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onRemoveClicked(_:)))
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        let vc = PicVC(pic: pics[index], navHiddenInitially: true, isPrivate: isPrivate)
        pager.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        pager.dataSource = self
        pager.delegate = self
        addChildViewController(pager)
        pager.didMove(toParentViewController: self)
        view.addSubview(pager.view)
        pager.view.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    @objc func onRemoveClicked(_ sender: UIBarButtonItem) {
        goToPics()
        if index < pics.count {
            delegate.removePic(key: pics[index].meta.key)
        }
    }
    
    func goToPics() {
        navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension PicPagingVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let current = pageViewController.viewControllers?.first as? PicVC else { return }
            guard let newIndex = self.pics.index(where: { p in p.meta.key == current.pic.meta.key || (p.meta.clientKey != nil && p.meta.clientKey == current.pic.meta.clientKey) }) else { return }
            index = newIndex
        }
    }
}

extension PicPagingVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return go(to: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return go(to: index + 1)
    }
    
    func go(to newIndex: Int) -> UIViewController? {
        if newIndex >= 0 && newIndex < pics.count {
            return PicVC(pic: pics[newIndex], navHiddenInitially: navigationController?.isNavigationBarHidden ?? true, isPrivate: isPrivate)
        } else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pics.count
    }
    
    // If uncommented, shows the paging indicator (dots highlighting the current index)
    // This is only an annoyance in this app, IMO, so it remains commented
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return index
//    }
}
