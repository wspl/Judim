//
//  SiteViewController.swift
//  Judim
//
//  Created by Plutonist on 2017/4/3.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import SnapKit
import Hydra
import RxSwift
import RxCocoa
import NVActivityIndicatorView
import Spruce


class SiteViewController: BaseViewController {
    
    var tableViewContentOffset: CGFloat = 110

    var nav: PLNavBar!
    var tableView: UITableView!
    var infoView: SiteInfoView!
    var refresh: PLRefresh!
    var loadMore: PLLoadMore!
    
    var postViewController: PostViewController?

    var viewModel = SiteViewModel()
    let disposeBag = DisposeBag()
    
    override func render(root: PLUi<UIView>) {
        ThemeUtils.ApplyGradient(view: view)
        
        nav = root.put(PLNavBar().withBack().title("站点").done()) { node, this in
            this.snp.makeConstraints { make in
                make.top.equalTo(view).offset(20)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(44)
            }
        }
        
        tableView = root.put(UITableView(frame: CGRect.zero)) { node, this in
            this.tableFooterView = UIView()
            this.separatorInset = UIEdgeInsets(top: 0, left: 115, bottom: 0, right: 25)
            this.separatorColor = THEME_DIVIDER_COLOR
            loadMore = PLLoadMore().bind(viewController: self).bind(scrollView: this)
            
            this.snp.makeConstraints { make in
                make.top.equalTo(view).offset(64)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            }
        }

        infoView = root.put(SiteInfoView()) { node, this in
            this.snp.makeConstraints { make in
                make.top.equalTo(tableView)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(100)
            }
        }
        
        //postsTableView.transform = CGAffineTransform(translationX: 0, y: 100)
        tableView.scrollIndicatorInsets.top = 100
        tableView.contentInset.top = tableViewContentOffset
        //postsTableView.addGestureRecognizer(pan)
        
        refresh = PLRefresh()
            .bind(navBar: nav)
            .bind(scrollView: tableView)
            .bind(extraViews: [infoView])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // Refresh
        viewModel.loadPublisher
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { event in
                switch event {
                case .refreshFinished:
                    self.refresh.stopLoading()
                    self.tableView.reloadData()
                case .refreshFailed:
                    self.refresh.stopLoading(isFailed: true)
                case.loadMoreFinished, .loadMoreFailed:
                    self.loadMore.stopLoadMore()
                    self.tableView.reloadData()
                }
            }, onError: { error in
                print(error.localizedDescription)
            }).addDisposableTo(disposeBag)
        
        loadMore.setLoadMore { self.viewModel.more() }
        refresh.setReload { self.viewModel.reload() }
        
        refresh.startLoading()
    }
}

extension SiteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.configure(post: viewModel.posts.value[indexPath.row])
        return cell
    }
}

extension SiteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if postViewController == nil {
            let viewModel = PostViewModel(post: self.viewModel.posts.value[indexPath.row])
            postViewController = PostViewController(viewModel: viewModel)
        } else {
            postViewController!.restore()
            postViewController!.viewModel.post.value = self.viewModel.posts.value[indexPath.row]
            postViewController!.refresh.startLoading(noAction: true)
            postViewController!.viewModel.restore()
        }
        RootNav.sharedInstance.pushViewController(postViewController!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.posts.value.count - 1 && !loadMore.isLoading {
            tableView.tableFooterView = loadMore
            loadMore.startLoadMore()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let relativeOffset = scrollView.contentOffset.y + tableViewContentOffset
        
        if infoView.frame.size.height >= 50 {
            //postsTableViewContentOffset = relativeOffset
            var frame = infoView.frame
            frame.size.height = relativeOffset > 50 ? 50 : 100 - relativeOffset
            infoView.frame = frame
        }
    }
}
