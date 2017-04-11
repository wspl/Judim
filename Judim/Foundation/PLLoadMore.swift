//
//  PLLoadMore.swift
//  Judim
//
//  Created by Plutonist on 2017/4/11.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

enum PLLoadMoreEvent {
    case loadMore
    case loadMoreFinished
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
