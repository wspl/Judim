//
//  PLLoad.swift
//  Judim
//
//  Created by Plutonist on 2017/4/13.
//  Copyright © 2017年 Plutonist. All rights reserved.
//


import UIKit
import NVActivityIndicatorView

enum PLLoadEvent {
    case loadMoreFinished
    case refreshFinished
    case loadMoreFailed
    case refreshFailed
}

class PLLoadMore: UIView {
    weak var viewController: UIViewController?
    weak var scrollView: UIScrollView?
    var indicator: NVActivityIndicatorView!
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.shadowColor = THEME_TEXT_REGULAR_COLOR.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowRadius = 1
        indicator = NVActivityIndicatorView(
            frame: CGRect(x: 5, y: 5, width: 20, height: 20),
            type: .ballRotate,
            color: THEME_COLOR)
        addSubview(indicator)
    }
    
    func bind(viewController: UIViewController) -> PLLoadMore {
        self.viewController = viewController
        viewController.view.addSubview(self)
        return self
    }
    
    func bind(scrollView: UIScrollView) -> PLLoadMore {
        self.scrollView = scrollView
        snp.makeConstraints { make in
            make.size.equalTo(30)
            make.centerX.equalTo(scrollView)
            make.bottom.equalTo(scrollView).offset(-10)
        }
        self.transform = CGAffineTransform(translationX: 0, y: 50)
        return self
    }
    
    var isLoading: Bool = false
    
    func startLoadMore(noAction: Bool = false) {
        isLoading = true
        if !noAction {
            loadCallback?()
        }
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        indicator.startAnimating()
    }
    
    func stopLoadMore() {
        isLoading = false
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: 50)
        }
        indicator.stopAnimating()
    }
    
    func setLoadMore(call: @escaping () -> ()) {
        self.loadCallback = call
    }
    
    var loadCallback: (() -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PLRefresh {
    var loadingView: NVActivityIndicatorView!
    var loadingText: UILabel!
    
    weak var navBar: PLNavBar!
    weak var scrollView: UIScrollView!
    var movableViews = [UIView]()
    
    func bind(navBar: PLNavBar) -> PLRefresh {
        self.navBar = navBar
        let node = PLUi(view: self.navBar)
        
        loadingView = node.put(NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 20, height: 20),
            type: .ballBeat,
            color: .white
        )) { node, this in
            this.alpha = 0
            this.snp.makeConstraints { make in
                make.top.equalTo(this.superview!).offset(44)
                make.centerX.equalTo(this.superview!)
            }
        }
        
        loadingText = node.put(UILabel()) { node, this in
            this.textColor = .white
            this.font = this.font.withSize(10)
            this.text = "重新加载"
            this.alpha = 0
            this.transform = CGAffineTransform(translationX: 0, y: -8)
            this.snp.makeConstraints { make in
                make.top.equalTo(this.superview!).offset(44)
                make.height.equalTo(20)
                make.centerX.equalTo(this.superview!)
            }
        }
        
        return self
    }
    
    func bind(scrollView: UIScrollView) -> PLRefresh {
        self.scrollView = scrollView
        self.scrollView.bounces = false
        self.scrollView.panGestureRecognizer.addTarget(self, action: #selector(panButton(pan:)))
        return self
    }
    
    func bind(extraViews: [UIView]) -> PLRefresh {
        self.movableViews.append(contentsOf: extraViews)
        return self
    }
    
    func setReload(call: @escaping () -> ()) {
        self.loadCallback = call
    }
    
    
    var beginY: CGFloat = 0
    var dragDistance: CGFloat = 0
    var bouncesDistance: CGFloat = 0
    var loadingAble = false
    var isLoading = false
    var isRestoring = false
    
    let dragFit: CGFloat = 50
    let bounceFit: CGFloat = 30
    lazy var k: CGFloat = self.bounceFit / sqrt(self.dragFit)
    
    @objc private func panButton(pan: UIPanGestureRecognizer) {
        let y = pan.location(in: navBar).y
        if pan.state == .began {
            beginY = y
        }
        
        if !isLoading && !isRestoring {
            
            dragDistance = y - beginY
            bouncesDistance = k * sqrt(dragDistance > 0 ? dragDistance : 0)
            
            if pan.state != .ended {
                if scrollView.contentOffset.y == -scrollView.contentInset.top && y > beginY {
                    scrollView.transform = CGAffineTransform(translationX: 0, y: bouncesDistance)
                    movableViews.forEach { $0.transform = CGAffineTransform(translationX: 0, y: bouncesDistance) }
                    
                    if bouncesDistance < bounceFit {
                        var bouncesPercent = bouncesDistance / bounceFit
                        if bouncesPercent > 1 { bouncesPercent = 1 }
                        
                        loadingText.transform = CGAffineTransform(translationX: 0, y: -8 * (1 - bouncesPercent))
                        loadingText.alpha = bouncesPercent
                    }
                    
                    if bouncesDistance >= bounceFit {
                        loadingAble = true
                    }
                } else {
                    scrollView.transform = CGAffineTransform(translationX: 0, y: 0)
                    movableViews.forEach { $0.transform = CGAffineTransform(translationX: 0, y: 0) }
                }
            }
        }
        
        if pan.state == .ended {
            guard loadingAble && bouncesDistance >= bounceFit else {
                return restore()
            }
            loadingAble = false
            startLoading()
        }
    }
    
    var loadCallback: (() -> ())?
    
    func startLoading(noAction: Bool = false) {
        if !noAction {
            loadCallback?()
        }
        loadingView.startAnimating()
        isLoading = true
        
        UIView.animate(withDuration: 0.2) {
            self.scrollView.transform = CGAffineTransform(translationX: 0, y: self.bounceFit)
            self.movableViews.forEach { $0.transform = CGAffineTransform(translationX: 0, y: self.bounceFit) }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.loadingText.alpha = 0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.loadingView.alpha = 1
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
        //            self.stopLoading()
        //        }
        
        loadingAble = false
    }
    
    private func restore() {
        isRestoring = true
        UIView.animate(withDuration: 0.1) {
            self.isRestoring = false
            self.scrollView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.movableViews.forEach { $0.transform = CGAffineTransform(translationX: 0, y: 0) }
            self.loadingText.alpha = 0
            self.loadingText.transform = CGAffineTransform(translationX: 0, y: -8)
        }
    }
    
    func stopLoading(isFailed: Bool = false) {
        self.loadingText.transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingView.alpha = 0
        }, completion: { _ in
            self.loadingText.text = isFailed ? "加载失败" : "加载好了"
            UIView.animate(withDuration: 0.2, animations: {
                self.loadingText.alpha = 1
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.scrollView.transform = CGAffineTransform(translationX: 0, y: 0)
                        self.movableViews.forEach { $0.transform = CGAffineTransform(translationX: 0, y: 0) }
                        self.loadingText.alpha = 0
                        self.loadingText.transform = CGAffineTransform(translationX: 0, y: -8)
                    }, completion: { _ in
                        self.loadingText.text = "重新加载"
                        self.isLoading = false
                        self.loadingView.stopAnimating()
                    })
                }
            })
        })
    }
}
