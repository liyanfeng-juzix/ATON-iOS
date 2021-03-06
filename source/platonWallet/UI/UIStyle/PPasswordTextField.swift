//
//  PPasswordTextField.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/24.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class PPasswordTextField: PTextFieldWithPadding {

    lazy var rightBtn: UIButton = {

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.setImage(UIImage(named: "pwdInvisable"), for: .normal)
        btn.setImage(UIImage(named: "pwdvisable"), for: .selected)
        btn.addTarget(self, action: #selector(switchTextSecureOrNot(_ :)), for: .touchUpInside)
        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        rightView = rightBtn
        rightViewMode = .always
        isSecureTextEntry = !rightBtn.isSelected
//        if #available(iOS 12, *) {
//            self.textContentType = .oneTimeCode
//        } else {
//            if #available(iOS 10.0, *) {
//                self.textContentType = .init(rawValue: "")
//            } else {
//                // Fallback on earlier versions
//            }
//        }
    }

    @objc func switchTextSecureOrNot(_ sender: Any) {

        guard let btn = sender as? UIButton else { return }
        btn.isSelected = !btn.isSelected
        isSecureTextEntry = !btn.isSelected

    }
}
