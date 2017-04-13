//
//  PostViewController.swift
//  Judim
//
//  Created by Plutonist on 2017/4/7.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PostViewController: BaseViewController {
    
    var nav: PLNavBar!
    var infoView: PostInfoView!
    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var refresh: PLRefresh!
    var loadMore: PLLoadMore!
    var zoomView: UIImageView!
    
    var picturesPageViewController: PicturesPageViewController?
    
    var viewModel: PostViewModel
    let disposeBag = DisposeBag()
    
    init(viewModel: PostViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func render(root: PLUi<UIView>) {
        ThemeUtils.ApplyGradient(view: view)
        
        nav = root.put(PLNavBar().withBack().title("画册").done()) { node, this in
            this.snp.makeConstraints { make in
                make.top.equalTo(view).offset(20)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(44)
            }
        }
        
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 5
        collectionViewFlowLayout.minimumInteritemSpacing = 5
        collectionView = root.put(UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)) { node, this in
            this.backgroundColor = .white
            this.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            loadMore = PLLoadMore().bind(viewController: self).bind(scrollView: this)
            
            this.snp.makeConstraints { make in
                make.top.equalTo(view).offset(64)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            }
        }
        
        infoView = root.put(PostInfoView()) { node, this in
            this.snp.makeConstraints { make in
                make.top.equalTo(collectionView)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(150)
            }
        }
        
        zoomView = root.put(UIImageView()) { node, this in
            this.backgroundColor = .clear
            this.contentMode = .scaleAspectFit
        }
        
        collectionView.scrollIndicatorInsets.top = 150
        collectionView.contentInset.top = 170
        
        refresh = PLRefresh()
            .bind(navBar: nav)
            .bind(scrollView: collectionView)
            .bind(extraViews: [infoView])
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data
        collectionView.register(PictureCell.self, forCellWithReuseIdentifier: "PictureCell")
        collectionView.delegate = self
        collectionView.dataSource = self

        // Refresh
        viewModel.loadPublisher
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { event in
                switch event {
                case .refreshFinished:
                    self.refresh.stopLoading()
                    self.collectionView.reloadData()
                case .refreshFailed:
                    self.refresh.stopLoading(isFailed: true)
                case.loadMoreFinished, .loadMoreFailed:
                    self.loadMore.stopLoadMore()
                    self.collectionView.reloadData()
                }
            }, onError: { error in
                print(error.localizedDescription)
            }).addDisposableTo(disposeBag)
        
        loadMore.setLoadMore { self.viewModel.more() }
        refresh.setReload { self.viewModel.reload() }
        
        refresh.startLoading()

        
        
        // InfoView
        infoView.configure(post: viewModel.post)
    }
    
    func zoomCellImage(at indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PictureCell
        let realFrame = cell.pictureView.convert(cell.pictureView.frame, to: view)
        zoomView.image = cell.pictureView.image
        UIView.animate(withDuration: 0.3) {
            self.zoomView.frame = realFrame
        }
    }
    
    func zoomInCellImage(from indexPath: IndexPath) {
        self.zoomView.isHidden = false
        let cell = collectionView.cellForItem(at: indexPath) as! PictureCell
        let realFrame = cell.pictureView.convert(cell.pictureView.frame, to: view)
        zoomView.image = cell.pictureView.image
        zoomView.frame = realFrame
        UIView.animate(withDuration: 0.3) {
            self.zoomView.frame = self.view.frame
            self.zoomView.alpha = 0
        }
    }
    
    func scrollPictures(to indexPath: IndexPath) {
        var atLine = Int(indexPath.row / 3) - 1
        if atLine < 0 {
            atLine = 0
        }
        let offset = (((collectionView.contentSize.width - 10) / 3) + 5) * CGFloat(atLine)
        self.collectionView.contentOffset.y = offset - collectionView.contentInset.top
    }
    
    func zoomOutCellImage(to indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath) as! PictureCell
        let realFrame = cell.pictureView.convert(cell.pictureView.frame, to: self.view)
        self.zoomView.image = cell.pictureView.image
        UIView.animate(withDuration: 0.3, animations: {
            self.zoomView.frame = realFrame
            self.zoomView.alpha = 1
        }, completion: { _ in
            self.zoomView.isHidden = true
        })
    }
    
    func restore() {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: -collectionView.contentInset.top), animated: false)
        viewModel.post.value = Post()
        collectionView.reloadData()
    }
}

extension PostViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.post.value.pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as! PictureCell
        cell.configure(picture: viewModel.post.value.pictures[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.contentSize.width - 10) / 3, height: (collectionView.contentSize.width - 10) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if picturesPageViewController == nil {
            picturesPageViewController = PicturesPageViewController(post: viewModel.post, index: indexPath.row, parent: self)
            picturesPageViewController!.modalPresentationStyle = .custom
            picturesPageViewController!.modalTransitionStyle = .crossDissolve
        }
        zoomInCellImage(from: indexPath)
        picturesPageViewController!.withIndex(index: indexPath.row)
        present(picturesPageViewController!, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y + scrollView.frame.size.height, scrollView.contentSize.height)
        if scrollView.contentSize.height > 0 {
            if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 50 {
                if !loadMore.isLoading && viewModel.post.value.hasNextPage {
                    loadMore.startLoadMore()
                }
            }
        }
    }
}
