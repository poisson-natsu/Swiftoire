//
//  RxTableViewController.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import UIKit

class RxTableViewController: RxViewController, UIScrollViewDelegate {

    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()

    let isHeaderLoading = BehaviorRelay(value: false)
    let isFooterLoading = BehaviorRelay(value: MJRefreshState.idle)
//    let isFooterLoading = BehaviorRelay(value: false)
//    let footerState = BehaviorRelay(value: MJRefreshState.idle)
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect(), style: .plain)
        view.emptyDataSetSource = self
        view.emptyDataSetDelegate = self
        view.separatorStyle = .none
        view.keyboardDismissMode = .onDrag
        view.rx.setDelegate(self).disposed(by: rx.disposeBag)
        return view
    }()
    
    public lazy var rxRefreshHeader: AppRefreshHeader = {
        let header = AppRefreshHeader(refreshingBlock: { [weak self] in
            self?.headerRefreshTrigger.onNext(())
        })
        header.isAutomaticallyChangeAlpha = true
        header.lastUpdatedTimeLabel?.isHidden = true
        return header
    }()
    public lazy var rxRefreshFooter: AppRefreshAutoGifFooter = {
        let footer = AppRefreshAutoGifFooter(refreshingBlock: { [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
//        footer.isHidden = true
        footer.isAutomaticallyChangeAlpha = false
        return footer
    }()

    var clearsSelectionOnViewWillAppear = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if clearsSelectionOnViewWillAppear == true {
            deselectSelectedRow()
        }
    }

    override func makeUI() {
        super.makeUI()
        
        stackView.spacing = 0
        stackView.insertArrangedSubview(tableView, at: 0)
        
        tableView.mj_header = rxRefreshHeader
        tableView.mj_footer = rxRefreshFooter
        
        isHeaderLoading.bind(to: tableView.rx.isAnimating).disposed(by: rx.disposeBag)
        isFooterLoading.bind(to: tableView.rx.refresh).disposed(by: rx.disposeBag)
    }
    
    override func updateUI() {
        super.updateUI()
    }

    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel?.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel?.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
//        viewModel?.footerState.asObservable().bind(to: footerState).disposed(by: rx.disposeBag)
        
        let updateEmptyDataSet = Observable.of(isLoading.mapToVoid().asObservable(),emptyDataSetImageTintColor.mapToVoid()).merge()
        updateEmptyDataSet.subscribe(onNext: {[weak self] () in
            self?.tableView.reloadEmptyDataSet()
        }).disposed(by: rx.disposeBag)
    }
}

extension RxTableViewController {

    func deselectSelectedRow() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            selectedIndexPaths.forEach({ (indexPath) in
                tableView.deselectRow(at: indexPath, animated: false)
            })
        }
    }
}

class AppRefreshHeader: MJRefreshGifHeader {
    
    ///初始化
    open override func prepare() {
        super.prepare()
        
        var images = [UIImage]()
        for index in 0..<16 {
            if let image = BundleLoad.loadImage(bundle: "AppRefresh", imageName: "dropdown_loading_\(index/10)\(index%10)@2x")?.withRenderingMode(.alwaysOriginal) {
                images.append(image)
            }
        }
        // 设置空闲状态的图片
        setImages(images, for: .idle)
        // 设置刷新状态的图片
        setImages(images, for: .refreshing)
        setTitle("刷新数据", for: .idle)
        setTitle("开始加载", for: .pulling)
        setTitle("刷新中", for: .refreshing)
        stateLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        //这里设置图片和文字的位置
        /*1 图片上文字下
        gifView?.contentMode = .center
        gifView?.frame = CGRect(x: 0, y: 4, width: mj_w, height: 25)
        stateLabel?.font = UIFont.systemFont(ofSize: 12)
        stateLabel?.frame = CGRect(x: 0, y: 35, width: mj_w, height: 14)
         */
    }
}

open class AppRefreshAutoGifFooter: MJRefreshAutoGifFooter {
    
    /// 初始化
    open override func prepare() {
        super.prepare()
        // 设置控件的高度
        mj_h = 50
        // 图片数组
        var images = [UIImage]()
        // 遍历
        for index in 0..<8 {
           
            if let image = BundleLoad.loadImage(bundle: "AppRefresh", imageName: "sendloading_18x18_\(index)@2x")?.withRenderingMode(.alwaysOriginal) {
                images.append(image)
            }
        }
        // 设置空闲状态的图片
        setImages(images, for: .idle)
        // 设置刷新状态的图片
        setImages(images, for: .refreshing)
//        setTitle("上拉加载数据", for: .idle)
        setTitle("", for: .idle)
        setTitle("正在努力加载", for: .pulling)
        setTitle("正在努力加载", for: .refreshing)
        setTitle("没有更多数据啦", for: .noMoreData)
        stateLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        if let f = gifView?.frame,
            let c = gifView?.center {
            
            var tempFrame = f
            tempFrame.origin.x = 135
            gifView?.frame = tempFrame
            
            var tempCenter = c
            tempCenter.y = stateLabel?.center.y ?? 0
            gifView?.center = tempCenter
        }
        
    }
    
}

