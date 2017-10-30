//
//  Validator.swift
//  TestValidator
//
//  Created by Ivan Sobolevskiy on 10/27/17.
//  Copyright © 2017 Ivan Sobolevskiy. All rights reserved.
//

//
//  Validator.swift
//  ethwall
//
//  Created by Ivan Sobolevskiy on 10/10/17.
//  Copyright © 2017 Ivan Sobolevskiy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol TextFieldMonitoring {
    func startMonitoring()
}

class TextFieldValidator {
    weak var textField: UITextField?
    
    let textIsValid: Variable<Bool>
    let disposeBag: DisposeBag
    
    let rule: (String?) -> Bool
    let validationFailedBlock: () -> Void
    let validationPassedBlock: () -> Void
    
    init(textField: UITextField, rule: @escaping (String?) -> Bool,
         validationFailedBlock: @escaping () -> Void,
         validationPassedBlock: @escaping () -> Void) {
        self.textField = textField
        self.rule = rule
        self.validationFailedBlock = validationFailedBlock
        self.validationPassedBlock = validationPassedBlock
        self.disposeBag = DisposeBag()
        self.textIsValid = Variable(false)
    }
}

extension TextFieldValidator: TextFieldMonitoring {
    func startMonitoring() {
        guard let textField = textField else { return }
        textField.rx.text.asDriver()
            .map { [weak self] text -> Bool in
                guard let `self` = self else { return false }
                return self.rule(text)
            }
            .drive(textIsValid)
            .disposed(by: disposeBag)
        
        setUpValidationMonitoring()
    }
    
    private func setUpValidationMonitoring() {
        textIsValid.asDriver()
            .drive(onNext: { [weak self] textIsValid -> Void in
                guard let `self` = self else { return }
                textIsValid ? self.validationPassedBlock() : self.validationFailedBlock()
            })
            .disposed(by: disposeBag)
    }
}
