//
//  RxTableViewController.swift
//  PowerTransport
//
//  Created by ไปๆๅ on 2021/4/2.
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
    
    ///ๅๅงๅ
    open override func prepare() {
        super.prepare()
        
        var images = [UIImage]()
        for index in 0..<16 {
            if let image = BundleLoad.loadImage(bundle: "AppRefresh", imageName: "dropdown_loading_\(index/10)\(index%10)@2x")?.withRenderingMode(.alwaysOriginal) {
                images.append(image)
            }
        }
        // ่ฎพ็ฝฎ็ฉบ้ฒ็ถๆ็ๅพ็
        setImages(images, for: .idle)
        // ่ฎพ็ฝฎๅทๆฐ็ถๆ็ๅพ็
        setImages(images, for: .refreshing)
        setTitle("ๅทๆฐๆฐๆฎ", for: .idle)
        setTitle("ๅผๅงๅ?่ฝฝ", for: .pulling)
        setTitle("ๅทๆฐไธญ", for: .refreshing)
        stateLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        //่ฟ้่ฎพ็ฝฎๅพ็ๅๆๅญ็ไฝ็ฝฎ
        /*1 ๅพ็ไธๆๅญไธ
        gifView?.contentMode = .center
        gifView?.frame = CGRect(x: 0, y: 4, width: mj_w, height: 25)
        stateLabel?.font = UIFont.systemFont(ofSize: 12)
        stateLabel?.frame = CGRect(x: 0, y: 35, width: mj_w, height: 14)
         */
    }
}

open class AppRefreshAutoGifFooter: MJRefreshAutoGifFooter {
    
    /// ๅๅงๅ
    open override func prepare() {
        super.prepare()
        // ่ฎพ็ฝฎๆงไปถ็้ซๅบฆ
        mj_h = 50
        // ๅพ็ๆฐ็ป
        var images = [UIImage]()
        // ้ๅ
        for index in 0..<8 {
           
            if let image = BundleLoad.loadImage(bundle: "AppRefresh", imageName: "sendloading_18x18_\(index)@2x")?.withRenderingMode(.alwaysOriginal) {
                images.append(image)
            }
        }
        // ่ฎพ็ฝฎ็ฉบ้ฒ็ถๆ็ๅพ็
        setImages(images, for: .idle)
        // ่ฎพ็ฝฎๅทๆฐ็ถๆ็ๅพ็
        setImages(images, for: .refreshing)
//        setTitle("ไธๆๅ?่ฝฝๆฐๆฎ", for: .idle)
        setTitle("", for: .idle)
        setTitle("ๆญฃๅจๅชๅๅ?่ฝฝ", for: .pulling)
        setTitle("ๆญฃๅจๅชๅๅ?่ฝฝ", for: .refreshing)
        setTitle("ๆฒกๆๆดๅคๆฐๆฎๅฆ", for: .noMoreData)
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

