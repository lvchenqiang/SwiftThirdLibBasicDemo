//
//  RXSwiftDemoVC.swift
//  SwiftThirdLibBasicDemo
//
//  Created by 吕陈强 on 2018/6/25.
//  Copyright © 2018年 吕陈强. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Result
import RxDataSources
import NSObject_Rx


class RXSwiftDemoVC: UIViewController {
    let disposed = DisposeBag()
    var label: UILabel =  {
        let lab = UILabel()
        lab.frame = CGRect(x: 50, y: 50, width: 200, height: 20)
        lab.textColor = UIColor.black
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.backgroundColor = UIColor.gray
        lab.text = "默认的文本"
        return lab;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label);
//        self.extensionLabReactiveFontSize()
//        self.test_PublishSubject()
//        self.test_BehaviorSubject()
//        self.test_ReplaySubject()
//        self.test_Variable()
//        self.test_buffer()
//        self.test_window()
//        self.test_map()
//        self.test_concatMap()
//        self.test_scan()
//        self.test_groupBy();
//        self.test_filter()
//        self.test_distinctUntilChanged()
//        self.test_single()
//        self.test_take()
//        self.test_takeLast()
//        self.test_skip()
//        self.test_Sample()
//        self.test_debounce();
//        self.test_amb()
//        self.test_skipWhile()
//        self.test_skipUntil()
//        self.test_reduce()
//        self.test_publish()
//        self.test_catchErrorJustReturn()
//        self.test_retry();
//        self.test_debug();
//        self.test_Resourcestotal();
//        self.test_SingleEvent();
//        self.test_asSingle()
//        self.test_CompletableEvent()
        self.test_MaybeEvent();
        
    }

}


// MARK:Observable 基础产生事件等
extension RXSwiftDemoVC{
    /// 了解Observable
    func learnObservable(){
        //这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
        //当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
        let observable = Observable<String>.create{observer in
            //对订阅者发出了.next事件，且携带了一个数据"hangge.com"
            observer.onNext("hangge.com")
            //对订阅者发出了.completed事件
            observer.onCompleted()
            //因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
            return Disposables.create()
        }
        
        //订阅测试
        observable.subscribe {
            print($0)
            }.disposed(by:disposed)
    }
    
    /// 了解Deferred初始化
    func learnDeferred(){
        //        该个方法相当于是创建一个 Observable 工厂，通过传入一个 block 来执行延迟 Observable序列创建的行为，而这个 block 里就是真正的实例化序列对象的地方
        //用于标记是奇数、还是偶数
        var isOdd = true
        //使用deferred()方法延迟Observable序列的初始化，通过传入的block来实现Observable序列的初始化并且返回。
        let factory : Observable<Int> = Observable.deferred {
            //让每次执行这个block时候都会让奇、偶数进行交替
            isOdd = !isOdd
            //根据isOdd参数，决定创建并返回的是奇数Observable、还是偶数Observable
            if isOdd {
                return Observable.of(1, 3, 5 ,7)
            }else {
                return Observable.of(2, 4, 6, 8)
            }
        }
        
        //第1次订阅测试
        factory.subscribe { event in
            print("\(isOdd)", event)
            }.disposed(by: disposed)
        
        //第2次订阅测试
        factory.subscribe { event in
            print("\(isOdd)", event)
            }.disposed(by: disposed)
        
        
    }
    /// 学习Interval
    func learnInterval(){
        //        （1）这个方法创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去。
        //
        //        （2）下面方法让其每 1 秒发送一次，并且是在主线程（MainScheduler）发送。
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        _ = observable.subscribe { event in
            print(event)
        }
        //        .disposed(by: disposed) 会自动释放
    }
    
    func learnTimer1(){
        //        （1）这个方法有两种用法，一种是创建的 Observable序列在经过设定的一段时间后，产生唯一的一个元素。
        //5秒种后发出唯一的一个元素0
        let observable = Observable<Int>.timer(5, scheduler: MainScheduler.instance)
        let _ = observable.subscribe { event in
            print(event)
        }
    }
    
    func learnTimer2(){
        //    2）另一种是创建的 Observable 序列在经过设定的一段时间后，每隔一段时间产生一个元素。
        //延时5秒种后，每隔1秒钟发出一个元素
        let observable = Observable<Int>.timer(5, period: 1, scheduler: MainScheduler.instance)
        let _ = observable.subscribe { event in
            print(event)
        }
        
    }
    
}

// MARK:Observable订阅、事件监听、订阅销毁
extension RXSwiftDemoVC{
    func observeevent(){
        
        //        let observable = Observable.of("A", "B", "C")
        //        observable.subscribe { event in
        //            print(event)
        //        }.disposed(by: disposed)
        //
        let observable = Observable.of("A", "B", "C")
        
        observable.subscribe(onNext: { element in
            print(element)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        }).disposed(by: disposed)
        
    }
    
    
    func doOnEvent(){
        /*
         （1）我们可以使用 doOn 方法来监听事件的生命周期，它会在每一次事件发送前被调用。
         
         （2）同时它和 subscribe 一样，可以通过不同的block 回调处理不同类型的 event。比如：
         
         do(onNext:)方法就是在subscribe(onNext:) 前调用
         而 do(onCompleted:) 方法则会在 subscribe(onCompleted:) 前面调用。
         */
        
        let observable = Observable.of("A", "B", "C")
        
        observable
            .do(onNext: { element in
                print("Intercepted Next：", element)
            }, onError: { error in
                print("Intercepted Error：", error)
            }, onCompleted: {
                print("Intercepted Completed")
            }, onDispose: {
                print("Intercepted Disposed")
            })
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            }).disposed(by: disposed)
        
        
    }
    
    
    func disposeBagEvent(){
        /*
         （1）除了 dispose()方法之外，我们更经常用到的是一个叫 DisposeBag 的对象来管理多个订阅行为的销毁：
         
         我们可以把一个 DisposeBag对象看成一个垃圾袋，把用过的订阅行为都放进去。
         而这个DisposeBag 就会在自己快要dealloc 的时候，对它里面的所有订阅行为都调用  dispose()方法。
         （2）下面是一个简单的使用样例。
         */
        let disposeBag = DisposeBag()
        
        //第1个Observable，及其订阅
        let observable1 = Observable.of("A", "B", "C")
        observable1.subscribe { event in
            print(event)
            }.disposed(by: disposeBag)
        
        //第2个Observable，及其订阅
        let observable2 = Observable.of(1, 2, 3)
        observable2.subscribe { event in
            print(event)
            }.disposed(by: disposeBag)
        
    }
    
}

// MARK:观察者1： AnyObserver、Binder
extension RXSwiftDemoVC
{
    /// 创建观察者
    func createObserverAndBind(){
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        _ =   observable
            .map { "当前索引数：\($0 )"}
            .bind {(text) in
                //收到发出的索引数后显示到label上
                debugPrint(text);
        }
        //            .disposed(by: disposed)
    }
    
    func createAnyObserverAndBind(){
        
        //观察者 AnyObserver 可以用来描叙任意一种观察者
        let observer: AnyObserver<String> = AnyObserver {(event) in
            switch event {
            case .next(let text):
                debugPrint(text);
            default:
                break
            }
        }
        
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        _ = observable
            .map { "当前索引数：\($0 )"}
            .bind(to: observer)
        //            .disposed(by: disposed)
        
    }
    func createBinderAndBind()
    {
        //        （1）相较于AnyObserver 的大而全，Binder 更专注于特定的场景。Binder 主要有以下两个特征：
        //
        //        不会处理错误事件
        //        确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
        //        （2）一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息。
        
        //观察者
        let observer: Binder<String> = Binder(self.label) { (view, text) in
            //收到发出的索引数后显示到label上
            view.text = text
        }
        
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        _ =  observable
            .map { "当前索引数：\($0 )"}
            .bind(to: observer)
        //            .disposed(by: disposeBag)
        
    }
}

// MARK:观察者2： 自定义可绑定属性
extension RXSwiftDemoVC
{
    func extensionLabFontSize(){
        //Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable
            .map { CGFloat($0) }
            .bind(to: self.label.fontSize) //根据索引数不断变放大字体
            .disposed(by: disposed)
        
    }
    
    func extensionLabReactiveFontSize(){
        //Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable
            .map { CGFloat($0) }
            .bind(to: label.rx.fontSize) //根据索引数不断变放大字体
            .disposed(by: disposed)
    
    }
    
}


extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

// MARK: Subjects、Variables
extension RXSwiftDemoVC
{
    /*
      Subjects 基本介绍
     （1）Subjects 既是订阅者，也是 Observable：
     
     说它是订阅者，是因为它能够动态地接收新的值。
     说它又是一个 Observable，是因为当 Subjects 有了新的值之后，就会通过 Event 将新值发出给他的所有订阅者。
     （2）一共有四种 Subjects，分别为：PublishSubject、BehaviorSubject、ReplaySubject、Variable。他们之间既有各自的特点，也有相同之处：
     
     首先他们都是 Observable，他们的订阅者都能收到他们发出的新的 Event。
     直到 Subject 发出 .complete 或者 .error 的 Event 后，该 Subject 便终结了，同时它也就不会再发出.next事件。
     对于那些在 Subject 终结后再订阅他的订阅者，也能收到 subject发出的一条 .complete 或 .error的 event，告诉这个新的订阅者它已经终结了。
     他们之间最大的区别只是在于：当一个新的订阅者刚订阅它的时候，能不能收到 Subject 以前发出过的旧 Event，如果能的话又能收到多少个。
     （3）Subject 常用的几个方法：
     
     onNext(:)：是 on(.next(:)) 的简便写法。该方法相当于 subject 接收到一个.next 事件。
     onError(:)：是 on(.error(:)) 的简便写法。该方法相当于 subject 接收到一个 .error 事件。
     onCompleted()：是 on(.completed)的简便写法。该方法相当于 subject 接收到一个  .completed 事件。
     */
    
    func test_PublishSubject(){
    /*
     PublishSubject是最普通的 Subject，它不需要初始值就能创建。
     PublishSubject 的订阅者从他们开始订阅的时间点起，可以收到订阅后 Subject 发出的新 Event，而不会收到他们在订阅前已发出的 Event
     */
        let disposeBag = DisposeBag()
        
        //创建一个PublishSubject
        let subject = PublishSubject<String>()
        
        //由于当前没有任何订阅者，所以这条信息不会输出到控制台
        subject.onNext("111")
        
        //第1次订阅subject
        subject.subscribe(onNext: { string in
            print("第1次订阅：", string)
        }, onCompleted:{
            print("第1次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
        //当前有1个订阅，则该信息会输出到控制台
        subject.onNext("222")
        
        //第2次订阅subject
        subject.subscribe(onNext: { string in
            print("第2次订阅：", string)
        }, onCompleted:{
            print("第2次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
        //当前有2个订阅，则该信息会输出到控制台
        subject.onNext("333")
        
        //让subject结束
        subject.onCompleted()
        
        //subject完成后不会再发出.next事件了。
        subject.onNext("444")
        
        //subject完成后它的所有订阅（包括结束后的订阅），都能收到subject的.completed事件，
        subject.subscribe(onNext: { string in
            print("第3次订阅：", string)
        }, onCompleted:{
            print("第3次订阅：onCompleted")
        }).disposed(by: disposeBag)
  
    }
    
    func test_BehaviorSubject(){
        /*
         BehaviorSubject 需要通过一个默认初始值来创建。
         当一个订阅者来订阅它的时候，这个订阅者会立即收到 BehaviorSubjects 上一个发出的event。之后就跟正常的情况一样，它也会接收到 BehaviorSubject 之后发出的新的 event。
         */
        
        let disposeBag = DisposeBag()
        
        //创建一个BehaviorSubject
        let subject = BehaviorSubject(value: "111")
        
        //第1次订阅subject
        subject.subscribe { event in
            print("第1次订阅：", event)
            }.disposed(by: disposeBag)
        
        //发送next事件
        subject.onNext("222")
        
        //发送error事件
        subject.onError(NSError(domain: "local", code: 0, userInfo: nil))
        
        //让subject结束
//        subject.onCompleted()
        
        
        //第2次订阅subject
        subject.subscribe { event in
            print("第2次订阅：", event)
            }.disposed(by: disposeBag)
    }
    
    func test_ReplaySubject(){
        /*
         ReplaySubject 在创建时候需要设置一个 bufferSize，表示它对于它发送过的 event 的缓存个数。
         比如一个 ReplaySubject 的 bufferSize 设置为 2，它发出了 3 个 .next 的 event，那么它会将后两个（最近的两个）event 给缓存起来。此时如果有一个 subscriber 订阅了这个 ReplaySubject，那么这个 subscriber 就会立即收到前面缓存的两个.next 的 event。
         如果一个 subscriber 订阅已经结束的 ReplaySubject，除了会收到缓存的 .next 的 event外，还会收到那个终结的 .error 或者 .complete 的event
          */
        
        let disposeBag = DisposeBag()
        
        //创建一个bufferSize为2的ReplaySubject
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        
        //连续发送3个next事件
        subject.onNext("111")
        subject.onNext("222")
        subject.onNext("333")
        
        //第1次订阅subject
        subject.subscribe { event in
            print("第1次订阅：", event)
            }.disposed(by: disposeBag)
        
        //再发送1个next事件
        subject.onNext("444")
        
        //第2次订阅subject
        subject.subscribe { event in
            print("第2次订阅：", event)
            }.disposed(by: disposeBag)
        
        //让subject结束
        subject.onCompleted()
        
        //第3次订阅subject
        subject.subscribe { event in
            print("第3次订阅：", event)
            }.disposed(by: disposeBag)
        
    }
    
    func test_Variable(){
        /*
         （1）基本介绍
         
         Variable 其实就是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
         Variable 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
         不同的是，Variable 还会把当前发出的值保存为自己的状态。同时它会在销毁时自动发送 .complete的 event，不需要也不能手动给 Variables 发送 completed或者 error 事件来结束它。
         简单地说就是 Variable 有一个 value 属性，我们改变这个 value 属性的值就相当于调用一般 Subjects 的 onNext() 方法，而这个最新的 onNext() 的值就被保存在 value 属性里了，直到我们再次修改它。
         注意：
         Variables 本身没有 subscribe() 方法，但是所有 Subjects 都有一个 asObservable() 方法。我们可以使用这个方法返回这个 Variable 的 Observable 类型，拿到这个 Observable 类型我们就能订阅它了。
         。
        */
        
        let disposeBag = DisposeBag()
        
        //创建一个初始值为111的Variable
        let variable = Variable("111")
        
        //修改value值
        variable.value = "222"
        
        //第1次订阅
        variable.asObservable().subscribe {
            print("第1次订阅：", $0)
            }.disposed(by: disposeBag)
        
        //修改value值
        variable.value = "333"
        
        //第2次订阅
        variable.asObservable().subscribe {
            print("第2次订阅：", $0)
            }.disposed(by: disposeBag)
        
        //修改value值
        variable.value = "444"
    
        /*
        注意：由于 Variable对象在viewDidLoad() 方法内初始化，所以它的生命周期就被限制在该方法内。当这个方法执行完毕后，这个 Variable 对象就会被销毁，同时它也就自动地向它的所有订阅者发出.completed 事件
         */
        
    }
}
// MARK:- 变换操作符：buffer、map、flatMap（已废弃->改用compactMap）、scan等
extension RXSwiftDemoVC
{
    func test_buffer(){
        let subject = PublishSubject<String>()
        /*
         buffer 方法作用是缓冲组合，第一个参数是缓冲时间，第二个参数是缓冲个数，第三个参数是线程。
         该方法简单来说就是缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
         */
        //每缓存3个元素则组合起来一起发出。
        //如果1秒钟内不够3个也会发出（有几个发几个，一个都没有发空数组 []）
        subject
            .buffer(timeSpan: 1, count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposed)
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")

    }
    
    func test_window(){
        /*
         window 操作符和 buffer 十分相似。不过 buffer 是周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
         同时 buffer要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列。
        */
        
        let subject = PublishSubject<String>()
        //每3个元素作为一个子Observable发出。
        subject
            .window(timeSpan: 1, count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self]  in
                print("subscribe: \($0)")
                $0.asObservable()
                    .subscribe(onNext: { print($0) })
                    .disposed(by: (self?.disposed)!)
            })
            .disposed(by: disposed)
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")

    }
    
    func test_map(){
        /*
         该操作符通过传入一个函数闭包把原来的 Observable 序列转变为一个新的 Observable 序列。
         */
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 3)
            .map { $0 * 10}
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func test_concatMap(){
        /*
         concatMap 与 flatMap 的唯一区别是：当前一个 Observable 元素发送完毕后，后一个Observable 才可以开始发出元素。或者说等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
        */
        
        let disposeBag = DisposeBag()
        
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        
        let variable = Variable(subject1)
        
        variable.asObservable()
            .concatMap { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("B")
        variable.value = subject2
        subject2.onNext("2")
        subject1.onNext("C")
        subject1.onCompleted()  ///只有前一个序列结束后，才能接收下一个序列
        /// subject1 调用onCompleted后结束了此序列 subject2 属于BehaviorSubject 保存最后的值2
        
    }
    
    func test_scan(){
        /*
         scan 就是先给一个初始化的数，然后不断的拿前一个结果和最新的值进行处理操作。
        */
        Observable.of(1, 2, 3, 4, 5)
            .scan(0) { acum, elem in
                debugPrint("acum:\(acum)")
                debugPrint("elem\(elem)")
                return   acum + elem
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposed)
        
           ///  scan(0)  默认会给一个初始的值    acum 会保存一个结果值 第一个值取得是 scan初始化的值
    }
    
    func test_groupBy(){
        /*
         groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
         也就是说该操作符会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
       */
        let disposeBag = DisposeBag()
        //将奇数偶数分成两组
        Observable<Int>.of(0, 1, 2, 3, 4, 5)
            .groupBy(keySelector: { (element) -> String in
                return element % 2 == 0 ? "偶数" : "基数"
            })
            .subscribe { (event) in
                switch event {
                case .next(let group):
                    group.asObservable().subscribe({ (event) in
                        print("key：\(group.key)    event：\(event)")
                    })
                        .disposed(by: disposeBag)
                default:
                    print("")
                }
            }
            .disposed(by: disposeBag)
    }
}
// MARK:- 过滤操作符：filter、take、skip等
extension RXSwiftDemoVC
{
    func test_filter(){
//        该操作符就是用来过滤掉某些不符合要求的事件。
        let disposeBag = DisposeBag()
        
        Observable.of(2, 30, 22, 5, 60, 3, 40 ,9)
            .filter {
                $0 > 10
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func test_distinctUntilChanged(){
//        该操作符用于过滤掉连续重复的事件
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 1, 1, 4)
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func test_single(){
        /*
         限制只发送一次事件，或者满足条件的第一个事件。
         如果存在有多个事件或者没有事件都会发出一个 error 事件。
         如果只有一个事件，则不会发出 error事件
         */
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 4)
            .single{ $0 == 2 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        Observable.of("A", "B", "C", "D")
            .single()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func test_elementAt(){
//        该方法实现只处理在指定位置的事件。
        let disposeBag = DisposeBag()
        Observable.of(1, 12, 3, 4)
            .elementAt(1)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    
    func test_ignoreElements(){
        /*
         该操作符可以忽略掉所有的元素，只发出 error或completed 事件。
         如果我们并不关心 Observable 的任何元素，只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符
         */
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 4)
            .ignoreElements()
            .subscribe{
                print($0)
            }
            .disposed(by: disposeBag)
    }
    
    func test_take(){
        // 该方法实现仅发送 Observable 序列中的前 n 个事件，在满足数量之后会自动 .completed。
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 3, 4)
            .take(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    
    func test_takeLast(){
        //        该方法实现仅发送 Observable序列中的后 n 个事件。
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 4)
            .takeLast(1)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func test_skip(){
        /// 该方法用于跳过源 Observable 序列发出的前 n 个事件
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 3, 4)
            .skip(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    func test_Sample(){
        // Sample 除了订阅源Observable 外，还可以监视另外一个 Observable， 即 notifier 。
//        每当收到 notifier 事件，就会从源序列取一个最新的事件并发送。而如果两次 notifier 事件之间没有源序列的事件，则不发送值。
        let disposeBag = DisposeBag()
        let source = PublishSubject<Int>()
        let notifier = PublishSubject<String>()
        
        source
            .sample(notifier)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        source.onNext(1)
        //让源序列接收接收消息
        notifier.onNext("A")
        source.onNext(2)
        //让源序列接收接收消息
        notifier.onNext("B")
        notifier.onNext("C")
        source.onNext(3)
        source.onNext(4)
        //让源序列接收接收消息
        notifier.onNext("D")
        source.onNext(5)
        //让源序列接收接收消息
        notifier.onCompleted()

        
    }
    
    func test_debounce(){
        /*
         debounce 操作符可以用来过滤掉高频产生的元素，它只会发出这种元素：该元素产生后，一段时间内没有新元素产生。
         换句话说就是，队列中的元素如果和下一个元素的间隔小于了指定的时间间隔，那么这个元素将被过滤掉。
         debounce 常用在用户输入的时候，不需要每个字母敲进去都发送一个事件，而是稍等一下取最后一个事件。
         */
        let times = [
            [ "value": 1, "time": 0.1 ],
            [ "value": 2, "time": 1.1 ],
            [ "value": 3, "time": 1.2 ],
            [ "value": 4, "time": 1.2 ],
            [ "value": 5, "time": 1.4 ],
            [ "value": 6, "time": 2.1 ]
        ]
        
        //生成对应的 Observable 序列并订阅
        Observable.from(times)
            .flatMap { item in
                return Observable.of(Int(item["value"]!))
                    .delaySubscription(Double(item["time"]!),
                                       scheduler: MainScheduler.instance)
            }
            .debounce(0.5, scheduler: MainScheduler.instance) //只发出与下一个间隔超过0.5秒的元素
            .subscribe(onNext: { print($0) })
            .disposed(by: disposed)
        
    }
    
}

// MARK:条件和布尔操作符：amb、takeWhile、skipWhile等
extension RXSwiftDemoVC{
    /*
     条件和布尔操作会根据条件发射或变换 Observables，或者对他们做布尔运算
      */
    func test_amb(){
        /*
         （1）基本介绍
         当传入多个 Observables 到 amb 操作符时，它将取第一个发出元素或产生事件的 Observable，然后只发出它的元素。并忽略掉其他的 Observables。
          */
        
        let disposeBag = DisposeBag()
        
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        let subject3 = PublishSubject<Int>()
        
        subject1
            .amb(subject2)
            .amb(subject3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject2.onNext(1)
        subject1.onNext(20)
        subject2.onNext(2)
        subject1.onNext(40)
        subject3.onNext(0)
        subject2.onNext(3)
        subject1.onNext(60)
        subject3.onNext(0)
        subject3.onNext(0)
        /*
         1
         2
         3
         */

    }
    
    
    func test_takeWhile(){
        /*
    该方法依次判断 Observable 序列的每一个值是否满足给定的条件。 当第一个不满足条件的值出现时，它便自动完成。
         */
        let disposeBag = DisposeBag()
        
        Observable.of(2, 3, 4, 5, 6)
            .takeWhile { $0 < 4 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    
    func test_takeUntil(){
        /*
         除了订阅源 Observable 外，通过 takeUntil 方法我们还可以监视另外一个 Observable， 即 notifier。
         如果 notifier 发出值或 complete 通知，那么源 Observable 便自动完成，停止发送事件。
         */
        
        let disposeBag = DisposeBag()
        
        let source = PublishSubject<String>()
        let notifier = PublishSubject<String>()
        
        source
            .takeUntil(notifier)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        source.onNext("a")
        source.onNext("b")
        source.onNext("c")
        source.onNext("d")
        
        //停止接收消息
        notifier.onNext("z")
        
        source.onNext("e")
        source.onNext("f")
        source.onNext("g")
        
    }
    
    func test_skipWhile(){
        /*
         该方法用于跳过前面所有满足条件的事件。
         一旦遇到不满足条件的事件，之后就不会再跳过了。
         */
        
        
        let disposeBag = DisposeBag()
        
        Observable.of(2, 3, 4, 5, 6,1)
            .skipWhile { $0 < 4 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
/*
         4
         5
         6
         1
 */
        
    }
    
    func test_skipUntil(){
        /*
         同上面的 takeUntil 一样，skipUntil 除了订阅源 Observable 外，通过 skipUntil方法我们还可以监视另外一个 Observable， 即 notifier 。
         与 takeUntil 相反的是。源 Observable 序列事件默认会一直跳过，直到 notifier 发出值或 complete 通知。
         */
        let disposeBag = DisposeBag()
        
        let source = PublishSubject<Int>()
        let notifier = PublishSubject<Int>()
        
        source
            .skipUntil(notifier)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        source.onNext(1)
        source.onNext(2)
        source.onNext(3)
        source.onNext(4)
        source.onNext(5)
        
        //开始接收消息
        notifier.onNext(0)
        
        source.onNext(6)
        source.onNext(7)
        source.onNext(8)
        
        //仍然接收消息
        notifier.onNext(0)
        
        source.onNext(9)

    }
}

// MARK:结合操作符：startWith、merge、zip等
extension RXSwiftDemoVC
{
    /*
    结合操作（或者称合并操作）指的是将多个 Observable 序列进行组合，拼装成一个新的  Observable 序列。
     */
    func test_startWith(){
    /*
     该方法会在 Observable 序列开始之前插入一些事件元素。即发出事件消息之前，会先发出这些预先插入的事件消息
    */
        
        let disposeBag = DisposeBag()
        
        Observable.of("2", "3")
            .startWith("1")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        /*
         1
         2
         3
         */
        /// 插入多个数据
        /*
        let disposeBag = DisposeBag()
        
        Observable.of("2", "3")
            .startWith("a")
            .startWith("b")
            .startWith("c")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         */
        

    }
    
    func test_merge(){
       /*
       该方法可以将多个（两个或两个以上的）Observable 序列合并成一个 Observable序列。
       */
        let disposeBag = DisposeBag()
        
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        
        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext(20)
        subject1.onNext(40)
        subject1.onNext(60)
        subject2.onNext(1)
        subject1.onNext(80)
        subject1.onNext(100)
        subject2.onNext(1)
        
    }
    
    func test_zip(){
        /*
         该方法可以将多个（两个或两个以上的）Observable 序列压缩成一个 Observable 序列。
         而且它会等到每个 Observable 事件一一对应地凑齐之后再合并。
         */
        
        let disposeBag = DisposeBag()
        
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()
        
        Observable.zip(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)

        
    }
    
    func test_combineLatest(){
        /*
         该方法同样是将多个（两个或两个以上的）Observable 序列元素进行合并。
         但与 zip 不同的是，每当任意一个 Observable 有新的事件发出时，它会将每个 Observable 序列的最新的一个事件元素进行合并。
         */
        
        let disposeBag = DisposeBag()
        
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()
        
        Observable.combineLatest(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)

    }
    
    func test_withLatestFrom(){
        /*
        该方法将两个 Observable 序列合并为一个。每当 self(首) 队列发射一个元素时，便从第二个序列中取出最新的一个值。
         */
        let disposeBag = DisposeBag()
        
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        subject1.withLatestFrom(subject2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("A")
        subject2.onNext("1")
        subject1.onNext("B")
        subject1.onNext("C")
        subject2.onNext("2")
        subject1.onNext("D")
        
        
        
    }
    
    func test_switchLatest(){
        /*
         switchLatest 有点像其他语言的switch 方法，可以对事件流进行转换。
         比如本来监听的 subject1，我可以通过更改 variable 里面的 value 更换事件源。变成监听 subject2。
         */
        
        let disposeBag = DisposeBag()
        
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        
        let variable = Variable(subject1)
        
        variable.asObservable()
            .switchLatest()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("B")
        subject1.onNext("C")
        
        //改变事件源
        variable.value = subject2
        subject1.onNext("D")
        subject2.onNext("2")
        
        //改变事件源
        variable.value = subject1
        subject2.onNext("3")
        subject1.onNext("E")
        /*
         A
         B
         C
         1
         2
         D
         E
         */
 
    }
}

// MARK:算数&聚合操作符：toArray、reduce、concat
extension RXSwiftDemoVC{
    func test_toArray(){
        // 该操作符先把一个序列转成一个数组，并作为一个单一的事件发送，然后结束
        
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3)
            .toArray()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    /*
     reduce 接受一个初始值，和一个操作符号。
     reduce 将给定的初始值，与序列里的每个值进行累计运算。得到一个最终结果，并将其作为单个值发送出去
     */
    func test_reduce(){
        let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 3, 4, 5)
            .reduce(0, accumulator: +)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    /*
     concat 会把多个 Observable 序列合并（串联）为一个 Observable 序列。
     并且只有当前面一个 Observable 序列发出了 completed 事件，才会开始发送下一个 Observable 序列事件
     */
    func test_concat(){
        let disposeBag = DisposeBag()
        
        let subject1 = BehaviorSubject(value: 1)
        let subject2 = BehaviorSubject(value: 2)
        
        let variable = Variable(subject1)
        variable.asObservable()
            .concat()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject2.onNext(2)
        subject1.onNext(1)
        subject1.onNext(1)
        subject1.onCompleted()
        
        variable.value = subject2
        subject2.onNext(2)

    }
}

// MARK:连接操作符：connect、publish、replay、multicas
extension RXSwiftDemoVC
{
    /*
     可连接的序列（Connectable Observable）：
     （1）可连接的序列和一般序列不同在于：有订阅时不会立刻开始发送事件消息，只有当调用 connect()之后才会开始发送值。
     （2）可连接的序列可以让所有的订阅者订阅后，才开始发出事件消息，从而保证我们想要的所有订阅者都能接收到事件消息。

     */
    
    func test_publish(){
        /*
       publish 方法会将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
         */
        
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .publish()
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //相当于把事件消息推迟了两秒
        delay(2) {
            _ = interval.connect()
        }
        
        //第二个订阅者（延迟5秒开始订阅）
        delay(5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
        

        
    }
    
    ///延迟执行
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - closure: 延迟执行的闭包
    public func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    /*
     replay 同上面的 publish 方法相同之处在于：会将将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
     replay 与 publish 不同在于：新的订阅者还能接收到订阅之前的事件消息（数量由设置的 bufferSize 决定）
     */
    func test_replay(){
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .replay(5)
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //相当于把事件消息推迟了两秒
        delay(2) {
            _ = interval.connect()
        }
        
        //第二个订阅者（延迟5秒开始订阅）
        delay(5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    /*
     multicast 方法同样是将一个正常的序列转换成一个可连接的序列。
     同时 multicast 方法还可以传入一个 Subject，每当序列发送事件时都会触发这个 Subject 的发送
     */
    func test_multicast(){
        
        
        //创建一个Subject（后面的multicast()方法中传入）
        let subject = PublishSubject<Int>()
        
        //这个Subject的订阅
        _ = subject
            .subscribe(onNext: { print("Subject: \($0)") })
        
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .multicast(subject)
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //相当于把事件消息推迟了两秒
        delay(2) {
            _ = interval.connect()
        }
        
        //第二个订阅者（延迟5秒开始订阅）
        delay(5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
        
    }
    /*
     refCount 操作符可以将可被连接的 Observable 转换为普通 Observable
     即该操作符可以自动连接和断开可连接的 Observable。当第一个观察者对可连接的Observable 订阅时，那么底层的 Observable 将被自动连接。当最后一个观察者离开时，那么底层的 Observable 将被自动断开连接
     
     */
    func test_refCount(){
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .publish()
            .refCount()
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //第二个订阅者（延迟5秒开始订阅）
        delay(5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }

    }
    /*
     该操作符将使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者。
     简单来说 shareReplay 就是 replay 和 refCount 的组合
     */
    func test_share(){
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .share(replay: 5)
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //第二个订阅者（延迟5秒开始订阅）
        delay(5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    
    
    
    
}
// MARK:其他操作符：delay、materialize、timeout等
extension RXSwiftDemoVC
{
    
    /*
    该操作符会将 Observable 的所有元素都先拖延一段设定好的时间，然后才将它们发送出来
     */
    func test_delay(){
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 1)
            .delay(3, scheduler: MainScheduler.instance) //元素延迟3秒才发出
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    /*
     使用该操作符可以进行延时订阅。即经过所设定的时间后，才对 Observable 进行订阅操作。
     */
    func test_delaySubscription(){
         let disposeBag = DisposeBag()
        
        Observable.of(1, 2, 1)
            .delaySubscription(3, scheduler: MainScheduler.instance) //延迟3秒才开始订阅
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    /*
     该操作符可以将序列产生的事件，转换成元素。
     通常一个有限的 Observable 将产生零个或者多个 onNext 事件，最后产生一个 onCompleted 或者onError事件。
     而 materialize 操作符会将 Observable 产生的这些事件全部转换成元素，然后发送出来。
     */
    func test_materialize(){
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 1)
            .materialize()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    /*
   该操作符的作用和 materialize 正好相反，它可以将 materialize 转换后的元素还原
     */
    func test_dematerialize(){
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 1)
            .materialize()
            .dematerialize()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    /*
     使用该操作符可以设置一个超时时间。如果源 Observable 在规定时间内没有发任何出元素，
     就产生一个超时的 error 事件
     */
    func test_timeout(){
        
        let disposeBag = DisposeBag()
        
        //定义好每个事件里的值以及发送的时间
        let times = [
            [ "value": 1, "time": 0 ],
            [ "value": 2, "time": 0.5 ],
            [ "value": 3, "time": 1.5 ],
            [ "value": 4, "time": 4 ],
            [ "value": 5, "time": 5 ]
        ]
        
        //生成对应的 Observable 序列并订阅
        Observable.from(times)
            .flatMap { item in
                return Observable.of(Int(item["value"]!))
                    .delaySubscription(Double(item["time"]!),
                                       scheduler: MainScheduler.instance)
            }
            .timeout(2, scheduler: MainScheduler.instance) //超过两秒没发出元素，则产生error事件
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
        
        /*
           1
           2
           3
         Sequence timeout
         */
    }
    /*
     使用 using 操作符创建 Observable 时，同时会创建一个可被清除的资源，
     一旦 Observable终止了，那么这个资源就会被清除掉了
     */
    func test_using(){
        //一个无限序列（每隔0.1秒创建一个序列数 ）
        let infiniteInterval$ = Observable<Int>
            .interval(0.1, scheduler: MainScheduler.instance)
            .do(
                onNext: { print("infinite$: \($0)") },
                onSubscribe: { print("开始订阅 infinite$")},
                onDispose: { print("销毁 infinite$")}
        )
        
        //一个有限序列（每隔0.5秒创建一个序列数，共创建三个 ）
        let limited$ = Observable<Int>
            .interval(0.5, scheduler: MainScheduler.instance)
            .take(2)
            .do(
                onNext: { print("limited$: \($0)") },
                onSubscribe: { print("开始订阅 limited$")},
                onDispose: { print("销毁 limited$")}
        )
        
        //使用using操作符创建序列
        let o: Observable<Int> = Observable.using({ () -> AnyDisposable in
            return AnyDisposable(infiniteInterval$.subscribe())
        }, observableFactory: { _ in return limited$ }
        )
        _ =  o.subscribe()

    }
    
}

class AnyDisposable: Disposable {
    let _dispose: () -> Void
    
    init(_ disposable: Disposable) {
        _dispose = disposable.dispose
    }
    
    func dispose() {
        _dispose()
    }
}
// MARK:错误处理操作符可以用来帮助我们对 Observable 发出的 error 事件做出响应，或者从错误中恢复
enum MyError: Error {
    case A
    case B
}

extension RXSwiftDemoVC
{
    /*
    当遇到 error 事件的时候，就返回指定的值，然后结束
     */
    func test_catchErrorJustReturn(){
        let disposeBag = DisposeBag()
        
        let sequenceThatFails = PublishSubject<String>()
        
        sequenceThatFails
            .catchErrorJustReturn("错误")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("a")
        sequenceThatFails.onNext("b")
        sequenceThatFails.onNext("c")
        sequenceThatFails.onError(MyError.A)
        sequenceThatFails.onNext("d")
        
    }
    /*
     该方法可以捕获 error，并对其进行处理。
     同时还能返回另一个 Observable 序列进行订阅（切换到新的序列）
     */
    func test_catchError(){
       
        let disposeBag = DisposeBag()
        
        let sequenceThatFails = PublishSubject<String>()
        let recoverySequence = Observable.of("1", "2", "3")
        
        sequenceThatFails
            .catchError {
                print("Error:", $0)
                return recoverySequence
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("a")
        sequenceThatFails.onNext("b")
        sequenceThatFails.onNext("c")
        sequenceThatFails.onError(MyError.A)
        sequenceThatFails.onNext("d")

   
        
    }
    
    /*
     使用该方法当遇到错误的时候，会重新订阅该序列。比如遇到网络请求失败时，可以进行重新连接。
     retry() 方法可以传入数字表示重试次数。不传的话只会重试一次。
     */
    func test_retry(){
        let disposeBag = DisposeBag()
        var count = 1
        
        let sequenceThatErrors = Observable<String>.create { observer in
            observer.onNext("a")
            observer.onNext("b")
            
            //让第一个订阅时发生错误
            if count == 1 {
                observer.onError(MyError.A)
                print("Error encountered")
                count += 1
            }
            
            observer.onNext("c")
            observer.onNext("d")
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        sequenceThatErrors
            .retry(2)  //重试2次（参数为空则只重试一次）
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
}

// MARK:调试操作
extension RXSwiftDemoVC
{
    /*
     我们可以将 debug 调试操作符添加到一个链式步骤当中，
     这样系统就能将所有的订阅者、事件、和处理等详细信息打印出来，方便我们开发调试。
     */
    func test_debug(){
        let disposeBag = DisposeBag()
        
        Observable.of("2", "3")
            .startWith("1")
            .debug()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        /// 传入标记参数等
        Observable.of("2", "3")
            .startWith("1")
            .debug("调试1")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        

    }
    /*
     通过将 RxSwift.Resources.total 打印出来，
     我们可以查看当前 RxSwift 申请的所有资源数量。这个在检查内存泄露的时候非常有用
     */
    func test_Resourcestotal(){
     
        print(RxSwift.Resources.total)
        
        let disposeBag = DisposeBag()
        
        print(RxSwift.Resources.total)
        
        Observable.of("BBB", "CCC")
            .startWith("AAA")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        print(RxSwift.Resources.total)
 
    }

}

// MARK:特征序列1：Single、Completable、Maybe
extension RXSwiftDemoVC
{
    func test_SingleEvent(){
        /*
         1，基本介绍
         Single 是 Observable 的另外一个版本。但它不像 Observable 可以发出多个元素，
         它要么只能发出一个元素，要么产生一个 error 事件。
         
         发出一个元素，或一个 error 事件
         不会共享状态变化
         
         2，应用场景
         Single 比较常见的例子就是执行 HTTP 请求，然后返回一个应答或错误。
         不过我们也可以用 Single 来描述任何只有一个元素的序列
         3，SingleEvent
         为方便使用，RxSwift 还为 Single 订阅提供了一个枚举（SingleEvent）：
         
         .success：里面包含该Single的一个元素值
         .error：用于包含错误
         
         public enum SingleEvent<Element> {
         case success(Element)
         case error(Swift.Error)
         }
         
         */
//         let disposeBag = DisposeBag()
        //获取第0个频道的歌曲信息
      _ = getPlaylist("0")
            .subscribe { event in
                switch event {
                case .success(let json):
                    print("JSON结果: ", json)
                    
                case .error(let error):
                    print("发生错误: ", error)
                }
            }
//            .disposed(by: disposeBag)
        
    }
    //获取豆瓣某频道下的歌曲信息
    func getPlaylist(_ channel: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            let url = "https://douban.fm/j/mine/playlist?"
                + "type=n&channel=\(channel)&from=mainsite"
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        single(.error(DataError.cantParseJSON))
                        return
                }
                
                single(.success(result))
            }
            
            task.resume()
            
            return Disposables.create {task.cancel()}
        }
    }
    
    //与数据相关的错误类型
    enum DataError: Error {
        case cantParseJSON
    }
    /// 我们可以通过调用 Observable 序列的.asSingle()方法，将它转换为 Single。
    func test_asSingle(){
        let disposeBag = DisposeBag()
        
        Observable.of("1")
            .asSingle()
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
    }
    
   
    func test_CompletableEvent(){
        /*
         1，基本介绍
         Completable 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，
         它要么只能产生一个 completed 事件，要么产生一个 error 事件。
         
         不会发出任何元素
         只会发出一个 completed 事件或者一个 error 事件
         不会共享状态变化
         2，应用场景
         Completable 和 Observable<Void> 有点类似。
         适用于那些只关心任务是否完成，而不需要在意任务返回值的情况。
         比如：在程序退出时将一些数据缓存到本地文件，供下次启动时加载。像这种情况我们只关心缓存是否成功。
         
         3，CompletableEvent
         为方便使用，RxSwift 为 Completable 订阅提供了一个枚举（CompletableEvent）：
         
         .completed：用于产生完成事件
         .error：用于产生一个错误
         
         public enum CompletableEvent {
         case error(Swift.Error)
         case completed
         }
         
         */
        let disposeBag = DisposeBag()
        cacheLocally()
            .subscribe { completable in
                switch completable {
                case .completed:
                    print("保存成功!")
                case .error(let error):
                    print("保存失败: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
        

    }
    
    //将数据缓存到本地
    func cacheLocally() -> Completable {
        return Completable.create { completable in
            //将数据缓存到本地（这里掠过具体的业务代码，随机成功或失败）
            let success = (arc4random() % 2 == 0)
            
            guard success else {
                completable(.error(CacheError.failedCaching))
                return Disposables.create {}
            }
            
            completable(.completed)
            return Disposables.create {}
        }
    }
    
    //与缓存相关的错误类型
    enum CacheError: Error {
        case failedCaching
    }
    
    func test_MaybeEvent(){
        /*
         1，基本介绍
         Maybe 同样是 Observable 的另外一个版本。它介于 Single 和 Completable 之间，它要么只能发出一个元素，要么产生一个 completed 事件，要么产生一个 error 事件。
         
         发出一个元素、或者一个 completed 事件、或者一个 error 事件
         不会共享状态变化
         2，应用场景
         Maybe 适合那种可能需要发出一个元素，又可能不需要发出的情况。
         
         3，MaybeEvent
         为方便使用，RxSwift 为 Maybe 订阅提供了一个枚举（MaybeEvent）：
         
         .success：里包含该 Maybe 的一个元素值
         .completed：用于产生完成事件
         .error：用于产生一个错误
         
         public enum MaybeEvent<Element> {
         case success(Element)
         case error(Swift.Error)
         case completed
         }
         
         */
      let disposeBag = DisposeBag()
      
        generateString()
            .subscribe { maybe in
                switch maybe {
                case .success(let element):
                    print("执行完毕，并获得元素：\(element)")
                case .completed:
                    print("执行完毕，且没有任何元素。")
                case .error(let error):
                    print("执行失败: \(error.localizedDescription)")
                    
                }
            }
            .disposed(by: disposeBag)

    }
    
    
    func generateString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            
            //成功并发出一个元素
            maybe(.success("hangge.com"))
            
            //成功但不发出任何元素
            maybe(.completed)
            
            //失败
            //maybe(.error(StringError.failedGenerate))
            
            return Disposables.create {}
        }
    }
    
    //与缓存相关的错误类型
    enum StringError: Error {
        case failedGenerate
    }
    /*
    1）我们可以通过调用 Observable 序列的 .asMaybe()方法，将它转换为 Maybe
     */
    func test_asMaybe(){
        let disposeBag = DisposeBag()
        
        Observable.of("1")
            .asMaybe()
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
    }
}


// MARK:特征序列2：Driver
extension RXSwiftDemoVC
{
    /*
     let results = query.rx.text
     .throttle(0.3, scheduler: MainScheduler.instance) //在主线程中操作，0.3秒内值若多次改变，取最后一次
     .flatMapLatest { query in //筛选出空值, 拍平序列
     fetchAutoCompleteItems(query) //向服务器请求一组结果
     }
     
     //将返回的结果绑定到用于显示结果数量的label上
     results
     .map { "\($0.count)" }
     .bind(to: resultCount.rx.text)
     .disposed(by: disposeBag)
     
     //将返回的结果绑定到tableView上
     results
     .bind(to: resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
     cell.textLabel?.text = "\(result)"
     }
     .disposed(by: disposeBag)
     
    
     
     但这个代码存在如下 3 个问题：
     
     1 如果 fetchAutoCompleteItems 的序列产生了一个错误（网络请求失败），
     这个错误将取消所有绑定。此后用户再输入一个新的关键字时，是无法发起新的网络请求。
     2 如果 fetchAutoCompleteItems 在后台返回序列，那么刷新页面也会在后台进行，这样就会出现异常崩溃。
     3 返回的结果被绑定到两个 UI 元素上。那就意味着，每次用户输入一个新的关键字时，
     就会分别为两个 UI元素发起 HTTP请求，这并不是我们想要的结果。
     

     
     let results = query.rx.text
     .throttle(0.3, scheduler: MainScheduler.instance)//在主线程中操作，0.3秒内值若多次改变，取最后一次
     .flatMapLatest { query in //筛选出空值, 拍平序列
     fetchAutoCompleteItems(query)   //向服务器请求一组结果
     .observeOn(MainScheduler.instance)  //将返回结果切换到到主线程上
     .catchErrorJustReturn([])       //错误被处理了，这样至少不会终止整个序列
     }
     .shareReplay(1)                //HTTP 请求是被共享的
     
     //将返回的结果绑定到显示结果数量的label上
     results
     .map { "\($0.count)" }
     .bind(to: resultCount.rx.text)
     .disposed(by: disposeBag)
     
     //将返回的结果绑定到tableView上
     results
     .bind(to: resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
     cell.textLabel?.text = "\(result)"
     }
     .disposed(by: disposeBag)
     
     
     
    */
    func test_Driver(){
        /*
         1，基本介绍
         （1）Driver 可以说是最复杂的 trait，它的目标是提供一种简便的方式在 UI 层编写响应式代码。
         
         （2）如果我们的序列满足如下特征，就可以使用它：
         
         不会产生 error 事件
         一定在主线程监听（MainScheduler）
         共享状态变化（shareReplayLatestWhileConnected）
         2，为什么要使用 Driver?
         （1）Driver 最常使用的场景应该就是需要用序列来驱动应用程序的情况了，比如：
         
         通过 CoreData 模型驱动 UI
         使用一个 UI 元素值（绑定）来驱动另一个 UI 元素值
         （2）与普通的操作系统驱动程序一样，如果出现序列错误，应用程序将停止响应用户输入。
         
         （3）在主线程上观察到这些元素也是极其重要的，因为 UI 元素和应用程序逻辑通常不是线程安全的。
         
         （4）此外，使用构建 Driver 的可观察的序列，它是共享状态变化。

         */
        
        
        /*
         代码讲解：
         （1）首先我们使用 asDriver 方法将 ControlProperty 转换为 Driver。
         （2）接着我们可以用 .asDriver(onErrorJustReturn: []) 方法将任何 Observable 序列都转成 Driver，因为我们知道序列转换为 Driver 要他满足 3 个条件：
         
         *   不会产生 error 事件
         *   一定在主线程监听（MainScheduler）
         *   共享状态变化（shareReplayLatestWhileConnected）
         
         而 asDriver(onErrorJustReturn: []) 相当于以下代码：
         let safeSequence = xs
         .observeOn(MainScheduler.instance) // 主线程监听
         .catchErrorJustReturn(onErrorJustReturn) // 无法产生错误
         .share(replay: 1, scope: .whileConnected)// 共享状态变化
         return Driver(raw: safeSequence) // 封装
         （3）同时在 Driver 中，框架已经默认帮我们加上了 shareReplayLatestWhileConnected，
         所以我们也没必要再加上"replay"相关的语句了。
         （4）最后记得使用 drive 而不是 bindTo
         由于 drive 方法只能被 Driver 调用。这意味着，如果代码存在 drive，
         那么这个序列不会产生错误事件并且一定在主线程监听。这样我们就可以安全的绑定 UI元素。
 
        
        
        let results = query.rx.text.asDriver()        // 将普通序列转换为 Driver
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { query in
                fetchAutoCompleteItems(query)
                    .asDriver(onErrorJustReturn: [])  // 仅仅提供发生错误时的备选返回值
        }
        
        //将返回的结果绑定到显示结果数量的label上
        results
            .map { "\($0.count)" }
            .drive(resultCount.rx.text) // 这里使用 drive 而不是 bindTo
            .disposed(by: disposeBag)
        
        //将返回的结果绑定到tableView上
        results
            .drive(resultsTableView.rx.items(cellIdentifier: "Cell")) { //  同样使用 drive 而不是 bindTo
                (_, result, cell) in
                cell.textLabel?.text = "\(result)"
            }
            .disposed(by: disposeBag)
        
            */
        
        
    }
    
    
}


// MARK:特征序列3：ControlProperty、 ControlEvent
extension RXSwiftDemoVC
{
    /*
     （1）ControlProperty 是专门用来描述 UI 控件属性，拥有该类型的属性都是被观察者（Observable）。
     
     （2）ControlProperty 具有以下特征：
     
     不会产生 error 事件
     一定在 MainScheduler 订阅（主线程订阅）
     一定在 MainScheduler 监听（主线程监听）
     共享状态变化
     
     */
    func test_ControlProperty(){
        //将textField输入的文字绑定到label上
//        textField.rx.text
//            .bind(to: label.rx.text)
//            .disposed(by: disposeBag)
    }
    
    /*
     1，基本介绍
     （1）ControlEvent 是专门用于描述 UI 所产生的事件，拥有该类型的属性都是被观察者（Observable）。
     
     （2）ControlEvent 和 ControlProperty 一样，都具有以下特征：
     
     不会产生 error 事件
     一定在 MainScheduler 订阅（主线程订阅）
     一定在 MainScheduler 监听（主线程监听）
     共享状态变化
     
     */
    func test_ControlEvent(){
        
//    let disposeBag = DisposeBag()
        //订阅按钮点击事件
//        button.rx.tap
//            .subscribe(onNext: {
//                print("欢迎访问hangge.com")
//            }).disposed(by: disposeBag)
        
    }

}

extension Reactive where Base: UIButton {
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}


// MARK:调度器 Schedulers
extension RXSwiftDemoVC
{
    /*
     1，基本介绍
     （1）调度器（Schedulers）是 RxSwift 实现多线程的核心模块，它主要用于控制任务在哪个线程或队列运行。
     
     （2）RxSwift 内置了如下几种 Scheduler：
     
     CurrentThreadScheduler：表示当前线程 Scheduler。（默认使用这个）
     MainScheduler：表示主线程。如果我们需要执行一些和 UI 相关的任务，就需要切换到该 Scheduler运行。
     SerialDispatchQueueScheduler：封装了 GCD 的串行队列。如果我们需要执行一些串行任务，可以切换到这个 Scheduler 运行。
     ConcurrentDispatchQueueScheduler：封装了 GCD 的并行队列。如果我们需要执行一些并发任务，可以切换到这个 Scheduler 运行。
     OperationQueueScheduler：封装了 NSOperationQueue。

     */
    func test_Scheduler(){
        let disposeBag = DisposeBag()
        let rxData: Observable<String> = Observable.deferred {
            Observable.of("1", "12", "123" , "123123")
        }
            
            rxData
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated)) //后台构建序列
                .observeOn(MainScheduler.instance)  //主线程监听并处理序列结果
                .subscribe({ [weak self] data in
//                    self?.data = data
                })
                .disposed(by: disposeBag)
        /*
 
         （1）subscribeOn()
         
         该方法决定数据序列的构建函数在哪个 Scheduler 上运行。
         比如上面样例，由于获取数据、解析数据需要花费一段时间的时间，所以通过 subscribeOn 将其切换到后台 Scheduler 来执行。这样可以避免主线程被阻塞。
         （2）observeOn()
         
         该方法决定在哪个 Scheduler 上监听这个数据序列。
         比如上面样例，我们获取并解析完毕数据后又通过 observeOn 方法切换到主线程来监听并且处理结果。
    
         */
  
    }
    
    
    
}


