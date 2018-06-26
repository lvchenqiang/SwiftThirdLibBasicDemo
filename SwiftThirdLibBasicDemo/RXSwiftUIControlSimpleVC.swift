//
//  RXSwiftUIControlSimpleVC.swift
//  SwiftThirdLibBasicDemo
//
//  Created by 吕陈强 on 2018/6/26.
//  Copyright © 2018年 吕陈强. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class RXSwiftUIControlSimpleVC: UIViewController {
   let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
//        self.test_uilabel();/// 文本绑定
//        self.test_uitextfiled();
        self.test_Throttling();
    }




}
// MARK:监听UILabel事件
extension RXSwiftUIControlSimpleVC
{
    
    func test_uilabel(){
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:40, width:300, height:100))
        self.view.addSubview(label)
        
        //创建一个计时器（每0.1秒发送一个索引数）
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
        
        //将已过去的时间格式化成想要的字符串，并绑定到label上
        //        timer.map{ String(format: "%0.2d:%0.2d.%0.1d",
        //                          arguments: [($0 / 600) % 600, ($0 % 600 ) / 10, $0 % 10]) }
        //            .bind(to: label.rx.text)
        //            .disposed(by: disposeBag)
        
        
        
        //将已过去的时间格式化成想要的字符串，并绑定到label上
        timer.map(formatTimeInterval)
            .bind(to: label.rx.attributedText)
            .disposed(by: disposeBag)
        
        
    }
    //将数字转成对应的富文本
    func formatTimeInterval(ms: NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d",
                            arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
        //富文本设置
        let attributeString = NSMutableAttributedString(string: string)
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        attributeString.addAttribute(NSAttributedStringKey.font,
                                     value: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                                     range: NSMakeRange(0, 5))
        //设置字体颜色
        attributeString.addAttribute(NSAttributedStringKey.foregroundColor,
                                     value: UIColor.white, range: NSMakeRange(0, 5))
        //设置文字背景颜色
        attributeString.addAttribute(NSAttributedStringKey.backgroundColor,
                                     value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString
    }
}

// MARK:监听UITextField事件
extension RXSwiftUIControlSimpleVC
{
    func test_uitextfiled(){
        
        //创建文本输入框
        let textField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        textField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(textField)
        
        //当文本框内容改变时，将内容输出到控制台上
//        textField.rx.text.orEmpty.asObservable()
//            .subscribe(onNext: {
//                print("您输入的是：\($0)")
//            })
//            .disposed(by: disposeBag)
        
        
        
        //当文本框内容改变时，将内容输出到控制台上
        textField.rx.text.orEmpty.changed
            .subscribe(onNext: {
                print("您输入的是：\($0)")
            })
            .disposed(by: disposeBag)
   
      
    }
    /*
    Throttling 是 RxSwift 的一个特性。因为有时当一些东西改变时，通常会做大量的逻辑操作。
     而使用 Throttling 特性，不会产生大量的逻辑操作，而是以一个小的合理的幅度去执行。比如做一些实时搜索功能时，
     这个特性很有用。
     */
    func test_Throttling(){
        //创建文本输入框
        let inputField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        inputField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(inputField)
        
        //创建文本输出框
        let outputField = UITextField(frame: CGRect(x:10, y:150, width:200, height:30))
        outputField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(outputField)
        
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:190, width:300, height:30))
        self.view.addSubview(label)
        
        //创建按钮
        let button:UIButton = UIButton(type:.system)
        button.frame = CGRect(x:20, y:230, width:40, height:30)
        button.setTitle("提交", for:.normal)
        self.view.addSubview(button)
        
        
        //当文本框内容改变
        let input = inputField.rx.text.orEmpty.asDriver() // 将普通序列转换为 Driver
            .throttle(2) //在主线程中操作，2秒内值若多次改变，取最后一次
        
        //内容绑定到另一个输入框中
        input.drive(outputField.rx.text)
            .disposed(by: disposeBag)
        
        //内容绑定到文本标签中
        input.map{ "当前字数：\($0.count)" }
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        
        //根据内容字数决定按钮是否可用
        input.map{ $0.count > 5 }
            .drive(button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    /*
     1）通过 rx.controlEvent 可以监听输入框的各种事件，且多个事件状态可以自由组合。除了各种 UI 控件都有的 touch 事件外，输入框还有如下几个独有的事件：
     
     editingDidBegin：开始编辑（开始输入内容）
     editingChanged：输入内容发生改变
     editingDidEnd：结束编辑
     editingDidEndOnExit：按下 return 键结束编辑
     allEditingEvents：包含前面的所有编辑相关事件

     */
    func test_uitextfiled_controlEvent(){
        //创建文本输入框
        let inputField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        inputField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(inputField)
        inputField.rx.controlEvent([.editingDidBegin]) //状态可以组合
            .asObservable()
            .subscribe(onNext: { _ in
                print("开始编辑内容!")
            }).disposed(by: disposeBag)
        
   
    }
    
}

extension RXSwiftUIControlSimpleVC
{
    func test_UITextView(){
        /*
         （1）UITextView 还封装了如下几个委托回调方法：
         
         didBeginEditing：开始编辑
         didEndEditing：结束编辑
         didChange：编辑内容发生改变
         didChangeSelection：选中部分发生变化
         */
        let textView = UITextView(frame: CGRect(x: 50, y: 100, width: 300, height: 200));
        textView.backgroundColor = UIColor.gray
        view.addSubview(textView);
        //开始编辑响应
        textView.rx.didBeginEditing
            .subscribe(onNext: {
                print("开始编辑")
            })
            .disposed(by: disposeBag)
        
        //结束编辑响应
        textView.rx.didEndEditing
            .subscribe(onNext: {
                print("结束编辑")
            })
            .disposed(by: disposeBag)
        
        //内容发生变化响应
        textView.rx.didChange
            .subscribe(onNext: {
                print("内容发生改变")
            })
            .disposed(by: disposeBag)
        
        //选中部分变化响应
        textView.rx.didChangeSelection
            .subscribe(onNext: {
                print("选中部分发生变化")
            })
            .disposed(by: disposeBag)
        
    }
}
