//
//  ViewController.swift
//  ThreadSafety
//
//  Created by Harshvardhan Arora on 27/03/22.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    @IBAction private func buttonTapped() {
        print("Button is responsive")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setup5()
    }

    private func setup1() {
        let subject = BehaviorSubject<Int>(value: 0)

        print("Start")

        subject
            .do(onNext: { _ in
                print("A")
                Thread.sleep(forTimeInterval: 5)
                print("B")
            })
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        print("End")
    }

    private func setup2() {
        let subject = BehaviorSubject<Int>(value: 0)

        print("Start")

        subject
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .do(onNext: { _ in
                print("A")
                Thread.sleep(forTimeInterval: 5)
                print("B")
            })
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        print("End")
    }

    private func setup3() {
        let subject = PublishSubject<Int>()
        let deadline: DispatchTime = .now() + .seconds(5)

        subject
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        let dispatch1 = DispatchQueue(label: "Dispatch 1", qos: .userInitiated)
        let dispatch2 = DispatchQueue(label: "Dispatch 2", qos: .userInitiated)

        dispatch1.asyncAfter(deadline: deadline) {
            subject.onNext(5)
        }

        dispatch2.asyncAfter(deadline: deadline) {
            subject.onNext(10)
        }
    }

    private func setup4() {
        let subject = PublishSubject<Int>()
        let deadline: DispatchTime = .now() + .seconds(5)

        subject
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        let dispatch1 = DispatchQueue.main
        let dispatch2 = DispatchQueue.main

        dispatch1.asyncAfter(deadline: deadline) {
            subject.onNext(5)
        }

        dispatch2.asyncAfter(deadline: deadline) {
            subject.onNext(10)
        }
    }

    private func setup5() {
        let subject = PublishSubject<Int>()
        let deadline: DispatchTime = .now() + .seconds(5)

        subject
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        let dispatch1 = DispatchQueue(label: "Dispatch 1", qos: .userInitiated)
        let dispatch2 = DispatchQueue(label: "Dispatch 2", qos: .userInitiated)
        let dispatch3 = DispatchQueue(label: "Serial Dispatch")

        dispatch1.asyncAfter(deadline: deadline) {
            dispatch3.async {
                subject.onNext(5)
            }
        }

        dispatch2.asyncAfter(deadline: deadline) {
            dispatch3.async {
                subject.onNext(10)
            }
        }
    }
    
}

