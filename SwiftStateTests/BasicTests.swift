//
//  BasicTests.swift
//  SwiftState
//
//  Created by Yasuhiro Inami on 2014/08/08.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import SwiftState
import XCTest

class BasicTests: _TestCase
{
    func testREADME()
    {
        let machine = StateMachine<MyState, MyEvent>(state: .State0)
        
        machine.addRoute(.State0 => .State1)
        machine.addRoute(nil => .State2) { context in println("Any => 2, msg=\(context.userInfo!)") }
        machine.addRoute(.State2 => nil) { context in println("2 => Any, msg=\(context.userInfo!)") }
        
        // add handler (handlerContext = (event, transition, order, userInfo))
        machine.addHandler(.State0 => .State1) { context in
            println("0 => 1")
        }
        
        // add errorHandler
        machine.addErrorHandler { (event, transition, order, userInfo) in
            println("[ERROR] \(transition.fromState) => \(transition.toState)")
        }
        
        // tryState 0 => 1 => 2 => 1 => 0
        machine <- .State1
        machine <- (.State2, "Hello")
        machine <- (.State1, "Bye")
        machine <- .State0  // fail: no 1 => 0
        
        println("machine.state = \(machine.state)")
    }
    
    func testExample()
    {
        let machine = StateMachine<MyState, String>(state: .State0)
        
        // add 0 => 1
        machine.addRoute(.State0 => .State1) { context in
            println("[Transition 0=>1] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")
        }
        // add 0 => 1 once more
        machine.addRoute(.State0 => .State1) { context in
            println("[Transition 0=>1b] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")
        }
        // add 2 => Any
        machine.addRoute(.State2 => nil) { context in
            println("[Transition exit 2] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw()) (Any)")
        }
        // add Any => 2
        machine.addRoute(nil => .State2) { context in
            println("[Transition Entry 2] \(context.transition.fromState.toRaw()) (Any) => \(context.transition.toState.toRaw())")
        }
        // add 1 => 0 (no handler)
        machine.addRoute(.State1 => .State0)
        
        // 0 => 1
        XCTAssertTrue(machine.hasRoute(.State0 => .State1))
        
        // 1 => 0
        XCTAssertTrue(machine.hasRoute(.State1 => .State0))
        
        // 2 => Any
        XCTAssertTrue(machine.hasRoute(.State2 => .State0))
        XCTAssertTrue(machine.hasRoute(.State2 => .State1))
        XCTAssertTrue(machine.hasRoute(.State2 => .State2))
        XCTAssertTrue(machine.hasRoute(.State2 => .State3))
        
        // Any => 2
        XCTAssertTrue(machine.hasRoute(.State0 => .State2))
        XCTAssertTrue(machine.hasRoute(.State1 => .State2))
        XCTAssertTrue(machine.hasRoute(.State3 => .State2))
        
        // others
        XCTAssertFalse(machine.hasRoute(.State0 => .State0))
        XCTAssertFalse(machine.hasRoute(.State0 => .State3))
        XCTAssertFalse(machine.hasRoute(.State1 => .State1))
        XCTAssertFalse(machine.hasRoute(.State1 => .State3))
        XCTAssertFalse(machine.hasRoute(.State3 => .State0))
        XCTAssertFalse(machine.hasRoute(.State3 => .State1))
        XCTAssertFalse(machine.hasRoute(.State3 => .State3))
        
        // error
        machine.addErrorHandler { context in
            println("[ERROR 1] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")
        }
        
        // entry
        machine.addEntryHandler(.State0) { context in
            println("[Entry 0] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")   // NOTE: this should not be called
        }
        machine.addEntryHandler(.State1) { context in
            println("[Entry 1] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")
        }
        machine.addEntryHandler(.State2) { context in
            println("[Entry 2] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw()), userInfo = \(context.userInfo)")
        }
        machine.addEntryHandler(.State2) { context in
            println("[Entry 2b] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw()), userInfo = \(context.userInfo)")
        }
        
        // exit
        machine.addExitHandler(.State0) { context in
            println("[Exit 0] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")
        }
        machine.addExitHandler(.State1) { context in
            println("[Exit 1] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw())")
        }
        machine.addExitHandler(.State2) { context in
            println("[Exit 2] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw()), userInfo = \(context.userInfo)")
        }
        machine.addExitHandler(.State2) { context in
            println("[Exit 2b] \(context.transition.fromState.toRaw()) => \(context.transition.toState.toRaw()), userInfo = \(context.userInfo)")
        }
        
        // tryState 0 => 1 => 2 => 1 => 0 => 3
        XCTAssertTrue(machine <- .State1)
        XCTAssertTrue(machine <- (.State2, "State2 activate"))
        XCTAssertTrue(machine <- (.State1, "State2 deactivate"))
        XCTAssertTrue(machine <- .State0)
        XCTAssertFalse(machine <- .State3)
        
        XCTAssertEqual(machine.state, MyState.State0)
    }
}