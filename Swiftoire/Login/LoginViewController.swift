//
//  LoginViewController.swift
//  PowerDelivery
//
//  Created by 付文华 on 2021/4/6.
//

import UIKit
import YYKit

class LoginViewController: RxViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    let sendCodeRelay: BehaviorRelay = BehaviorRelay(value: "")
    let sendCodeSubject = BehaviorRelay(value: false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? LoginViewModel else {return}
        
        let output = viewModel.transform(input: LoginViewModel.Input(loginTrigger: loginBtn.rx.tap.asDriver(), phoneTrigger: mobileInput.rx.value.orEmpty.asDriver(), passwdTrigger: codeInput.rx.value.orEmpty.asDriver()))
        
//        viewModel.negotiateChecked.bind(to: negotiateBtn.rx.isSelected).disposed(by: rx.disposeBag)
        negotiateBtn.rx.tap.asDriver().drive(onNext: { [weak self] () in
            viewModel.negotiateChecked.accept(self?.negotiateBtn.isSelected ?? false)
        }).disposed(by: rx.disposeBag)
        
        output.userInfo.drive(onNext: {(user) in
            PTApplication.shared.presentInitialScreen()
        }).disposed(by: rx.disposeBag)
    }
    
    override func makeUI() {
        super.makeUI()
        
        view.backgroundColor = .white
        contentView.addSubview(loginBtn)
        contentView.addSubview(mobileInput)
        contentView.addSubview(codeInput)
        contentView.addSubview(iconIV)
        contentView.addSubview(appNameLabel)
        contentView.addSubview(iconIV)
        
        contentView.addSubview(negotiateBtn)
        contentView.addSubview(negotiateContent)
        let topView = UIView(frame: .zero)
        contentView.addSubview(topView)
        topView.addSubview(iconIV)
        topView.addSubview(appNameLabel)
        topView.addSubview(tipLabel)
        let line1 = getOneLine()
        let line2 = getOneLine()
        let line3 = getOneLine()
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(line3)
        
        codeInput.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.centerY)
            make.left.right.height.equalTo(mobileInput)
            make.height.equalTo(50)
        }
        
        mobileInput.snp.makeConstraints { (make) in
            make.bottom.equalTo(codeInput.snp.top).offset(-10)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(codeInput)
        }
        
        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(mobileInput.snp.top)
        }
        
        iconIV.snp.makeConstraints { (make) in
            make.left.equalTo(mobileInput)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        appNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconIV.snp.right).offset(15)
            make.centerY.equalTo(iconIV)
        }
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconIV)
            make.top.equalTo(iconIV.snp.bottom)
            make.bottom.equalTo(mobileInput.snp.top)
        }
        negotiateBtn.snp.makeConstraints { (make) in
            make.left.equalTo(mobileInput)
            make.top.equalTo(codeInput.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        let w = kScreenW - 30 * 2 - 12 - 3
        let boundingBox = negotiateContent.text!.boundingRect(with: CGSize(width: w, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: negotiateContent.font!], context: nil)
        let h = ceil(boundingBox.height)
        
        negotiateContent.snp.makeConstraints { (make) in
            make.left.equalTo(negotiateBtn.snp.right).offset(3)
            make.right.equalTo(loginBtn)
            make.height.equalTo(h)
            make.top.equalTo(negotiateBtn).offset(-1)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(negotiateContent.snp.bottom).offset(30)
            make.left.right.equalTo(mobileInput)
            make.height.equalTo(50)
        }
        
        line1.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalTo(mobileInput)
        }
        line2.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.equalTo(mobileInput)
            make.bottom.equalTo(codeInput)
        }
        
        negotiateBtn.addTarget(self, action: #selector(agreeAction), for: .touchUpInside)
    }
    
    @objc private func agreeAction() {
        negotiateBtn.isSelected = !negotiateBtn.isSelected
    }
    
    lazy var mobileInput: RegularTextField = {
        let tf = RegularTextField(frame: .zero)
        tf.regularLimitCb = { "^(1([3-9]{1}([0-9]{0,9})?)?)?$" }
        tf.keyboardType = .phonePad
        tf.placeholder = "请输入手机号码"
        tf.clearButtonMode = .always
        tf.addLeftImage(UIImage(named: "login_mobile"), with: 10)
        
        return tf
    }()
    
    lazy var codeInput: RegularTextField = {
        let tf = RegularTextField(frame: .zero)
        tf.isSecureTextEntry = true
        tf.placeholder = "请输入密码"
        tf.addPaddingLeft(10)
        tf.cornerRadius = 5
        tf.addLeftImage(UIImage(named: "login_code"), with: 10)
        
        
        return tf
    }()
    
    lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.cornerRadius = 6
        btn.backgroundColor = .themeMain
        btn.setTitle("同意协议并注册/登录", for: .normal)
        
        return btn
    }()
    
    lazy var iconIV: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.backgroundColor = .themeImageBackground
        iv.cornerRadius = 4
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logo")
        
        return iv
    }()
    
    lazy var appNameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = .systemFont(ofSize: 24, weight: .medium)
        l.text = "来了，老弟"
        
        return l
    }()
    lazy var tipLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = .themeBlack
        l.text = "请登录/注册"
        
        return l
    }()
    lazy var versionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.text = "v1.0"
        l.textColor = .lightGray
        l.font = UIFont.systemFont(ofSize: 12)
        
        return l
    }()
    
    lazy var negotiateBtn: HHButton = {
        let btn = HHButton(type: .custom)
        btn.setImage(UIImage(named: "login_agree_normal"), for: .normal)
        btn.setImage(UIImage(named: "login_agree_selected"), for: .selected)
//        btn.backgroundColor = .orange
        
        return btn
    }()
    lazy var negotiateContent: YYLabel = {
        var text = NSMutableAttributedString(string: "首次登录自动注册鸿运宝账号，且已阅读并同意")
        var one = NSMutableAttributedString(string: "《隐私权政策》")
        one.setTextHighlight(one.rangeOfAll(), color: .themeMain, backgroundColor: .clear) { (containerView, text, range, rect) in
            print("点击了隐私权政策")
        }
        text.append(one)
        var l = YYLabel()
        l.attributedText = text
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 12)
        
        return l
    }()
    
    private func getOneLine() -> UIView {
        let line = UIView(frame: .zero)
        line.backgroundColor = .init(hex: "F0F0F0")
        return line
    }
}
