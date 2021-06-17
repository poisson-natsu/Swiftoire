//
//  RxViewController.swift
//  PowerTransport
//
//  Created by 付文华 on 2021/4/2.
//

import UIKit
import DZNEmptyDataSet

class RxViewController: ViewController
                        //, NVActivityIndicatorViewable
{
    
    var viewModel: ViewModel?
    
//    init(viewModel: ViewModel?) {
    init(viewModel: ViewModel?) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    let isLoading = BehaviorRelay(value: false)
    let error = PublishSubject<ApiError>()
    
    var automaticallyAdjustsLeftBarButtonItem = true
    var canOpenFlex = true
    
    var navigationTitle = "" {
        didSet {
            navigationItem.title = navigationTitle
        }
    }
    
    let spaceBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    
    let emptyDataSetButtonTap = PublishSubject<Void>()
    var emptyDataSetTitle = "无数据"
    var emptyDataSetAttributeTitle: NSAttributedString?
    var emptyDataSetDescription = ""
    var emptyDataSetImage = UIImage(named: "waybill_empty")
    var emptyDataSetImageTintColor = BehaviorRelay<UIColor?>(value: nil)
    
    let orientationEvent = PublishSubject<Void>()
    let motionShakeEvent = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindViewModel()
    }
    
    
    lazy var contentView: UIView = {
        let view = UIView()
        //        view.hero.id = "CententView"
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
        return view
    }()

    lazy var stackView: UIStackView = {
        let subviews: [UIView] = []
        let view = UIStackView(arrangedSubviews: subviews)
        view.axis = .vertical
        view.spacing = 0
        self.contentView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return view
    }()
    
    func makeUI() {
//        hero.isEnabled = true
        view.backgroundColor = .themeBackground
        updateUI()
    }

    func bindViewModel() {
        viewModel?.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel?.parsedError.asObservable().bind(to: error).disposed(by: rx.disposeBag)

        isLoading.observeOn(MainScheduler.instance).subscribe(onNext: { (isLoading) in
            if isLoading {
                self.showWaitingHUD()
            }else {
                self.hideWaitingHUD()
            }
        }).disposed(by: rx.disposeBag)
        // 主线程延时200毫秒提示消息，避免一直转圈问题
        viewModel?.error.asDriver().delay(RxTimeInterval.milliseconds(200)).drive(onNext: { (error) in
            if let error = error as? MoyaError {
                switch error {
                case .jsonMapping(let response):
                    guard let errorDict = try? response.mapJSON() as? [String: Any] else {
                        print("error---------------------------------------：\(String(data: response.data, encoding: .utf8) ?? "什么鬼，出岔子了"))")
                        self.showHUD("未知错误")
                        break
                    }
                    if let errorResponse = NetBody.deserialize(from: errorDict) {
                        if errorResponse.code == 1001 {
//                            NotificationCenter.default.post(name: NotificationForTokenInvalid, object: nil)
                        }else {
                            print("----------------------viewModel error, msg:\(errorResponse.msg)")
                            self.showHUD(errorResponse.msg)
                        }
                    }
                    break
                case .stringMapping(let response):
                    if let msg = String(data: response.data, encoding: .utf8), !msg.isEmpty {
                        self.showHUD(msg)
                    }else {
                        self.showHUD("出错啦，请重试")
                    }
                    break
                case .statusCode(let response):
                    
                    guard let errorDict = try? response.mapJSON() as? [String: Any] else {
                        break
                    }
//                        guard let internalError = InternalError.deserialize(from: errorDict) else {
//                            break
//                        }
                    if response.statusCode == 500, let message = errorDict["message"] as? String, message.contains("Token") {
                        // 回到登录页面
                        PTApplication.shared.presentLoginPage()
                    }else {
                        self.showHUD("请求失败，请重试或联系相关人员")
                    }
                case .underlying(let error, _):
                    if case let .sessionTaskFailed(error) = error.asAFError {
                        print("---------------------------:\(error.localizedDescription)")
                        self.showHUD(error.localizedDescription)
                    }else {
                        self.showHUD(error.localizedDescription)
                    }
                default:
                    self.showHUD(error.localizedDescription)
                    break
                }
            }
        }).disposed(by: rx.disposeBag)
        
        viewModel?.toast.asDriver().delay(RxTimeInterval.milliseconds(200)).drive(onNext: { (msg) in
            if !msg.isEmpty {
                PTApplication.shared.window?.showHUD(msg)
            }
        }).disposed(by: rx.disposeBag)
    }

    func updateUI() {

    }
}

extension RxViewController: DZNEmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyDataSetAttributeTitle ?? NSAttributedString(string: emptyDataSetTitle, attributes: [.font: UIFont.systemFont(ofSize: 16)])
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetDescription, attributes: [.font: UIFont.systemFont(ofSize: 15)])
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return emptyDataSetImage
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return emptyDataSetImageTintColor.value
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60
    }
}

extension RxViewController: DZNEmptyDataSetDelegate {

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !isLoading.value
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

//    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
//        emptyDataSetButtonTap.onNext(())
//    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        emptyDataSetButtonTap.onNext(())
    }
}
