//
//  Observable.swift
//  Doggies
//
//  Created by user on 06.11.2021.
//

import Foundation

class Observable<T> {

    var value: T {
        didSet {
            print("!!!!!!!!!!!!!!!!!!!!!!!!!")
            listener?(value)
        }
    }

    private var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        self.listener = closure
    }
}
