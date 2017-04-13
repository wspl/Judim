//
//  PicturesPageViewController.swift
//  Judim
//
//  Created by Plutonist on 2017/4/8.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PicturesPageViewController: UIPageViewController {
    var closeView: UIImageView!
    
    weak var post = Variable<Post>(Post())
    
    var currentIndex: Int = 0
    weak var postViewController: PostViewController?
//    
//    var beforePictureView: PictureViewController = PictureViewController()
//    var currentPictureView: PictureViewController = PictureViewController()
//    var afterPictureView: PictureViewController = PictureViewController()
//    
    var pictureViews = [Int: PictureViewController]()
    
    init(post: Variable<Post>, index: Int, parent: PostViewController) {
        self.post = post
        self.postViewController = parent

        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        
        withIndex(index: index)
    }
    
    func withIndex(index: Int) {
        currentIndex = index
        setViewControllers([getPictureViewController(index: index)],
                           direction: .forward,
                           animated: false,
                           completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPictureViewController(index: Int) -> PictureViewController {
        if pictureViews[index] == nil {
            pictureViews[index] = PictureViewController(index: index)
        }
        //if pictureViews[index]!.picture.value != post!.value.pictures[index] {
        //    //pictureViews[index]!.pictureView.image = nil
        //    pictureViews[index]!.picture.value = post!.value.pictures[index]
        //}
        
        pictureViews[index]!.configure(picture: post!.value.pictures[index])
        return pictureViews[index]!
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        closeView = UIImageView()
        view.addSubview(closeView)
        closeView.image = PLIcon.Ionicons
            .size(25)
            .color(THEME_TEXT_LIGHT_COLOR)
            .char("\u{f2d7}")
            .done()
        closeView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(15)
            make.top.equalTo(view).offset(30)
        }
        closeView.isUserInteractionEnabled = true
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(onTapClose))
        closeView.addGestureRecognizer(closeTap)
        
        dataSource = self
        delegate = self
    }

    func onTapClose() {
        dismiss(animated: true, completion: nil)
        postViewController!.zoomOutCellImage(to: IndexPath(row: currentIndex, section: 0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

extension PicturesPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard currentIndex > 0 else { return nil }
        return getPictureViewController(index: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard currentIndex < post!.value.pictures.count - 1 else { return nil }
        return getPictureViewController(index: currentIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        currentIndex = (viewControllers![0] as! PictureViewController).index
        postViewController!.scrollPictures(to: IndexPath(row: currentIndex, section: 0))
    }
}
