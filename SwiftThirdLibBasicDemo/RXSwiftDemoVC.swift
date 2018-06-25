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
        self.test_debounce();
        
        
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
