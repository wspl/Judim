//
//  PLUi.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class PLUi<TSelf> where TSelf: UIView {
    
    let view: TSelf
    
    init(view: TSelf) {
        self.view = view
    }
    
    func put<TChild>(
        _ node: TChild,
        closure: (_ node: PLUi<TChild>, _ this: TChild) -> ()
        ) -> TChild where TChild: UIView {
        
        self.view.addSubview(node)
        closure(PLUi<TChild>(view: node), node)
        
        return node
    }
    
    typealias UIComponentClosure<TSelf> = (_ node: PLUi<UIView>) -> TSelf where TSelf: UIView
    
    func include<TChild>(_ component: UIComponentClosure<TChild>) -> TChild where TChild: UIView {
        return component(PLUi<UIView>(view: self.view))
    }
    
    func require<TChild>(_ component: UIComponentClosure<TChild>) -> PLUiIncluded<TChild, TSelf> where TChild: UIView {
        let ui = PLUi<UIView>(view: self.view)
        let view = component(ui)
        return PLUiIncluded(view: view, parentView: self.view)
    }
    
}

class PLUiIncluded<TSelf, TParent> where TSelf: UIView, TParent: UIView {
    
    let view: TSelf
    let parent: TParent
    
    init(view: TSelf, parentView: TParent) {
        self.view = view
        self.parent = parentView
    }
    
    func update(closure: (_ node: PLUi<TSelf>, _ this: TSelf, _ parent: TParent) -> ()) -> TSelf {
        let ui = PLUi<TSelf>(view: self.view)
        closure(ui, view, parent)
        return self.view
    }
    
}

