/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains an NSOperationQueue subclass.
*/

import Foundation

/**
    The delegate of an `OperationQueue` can respond to `Operation` lifecycle
    events by implementing these methods.

    In general, implementing `OperationQueueDelegate` is not necessary; you would
    want to use an `OperationObserver` instead. However, there are a couple of
    situations where using `OperationQueueDelegate` can lead to simpler code.
    For example, `GroupOperation` is the delegate of its own internal
    `OperationQueue` and uses it to manage dependencies.
*/
@objc protocol OperationQueueDelegate: NSObjectProtocol {
    optional func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation)
    optional func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError])
}

/**
    `OperationQueue` is an `NSOperationQueue` subclass that implements a large
    number of "extra features" related to the `Operation` class:
    
    - Notifying a delegate of all operation completion
    - Extracting generated dependencies from operation conditions
    - Setting up dependencies to enforce mutual exclusivity
*/
public class OperationQueue: NSOperationQueue {
    weak var delegate: OperationQueueDelegate?
    
    override public func addOperation(operation: NSOperation) {
        if let op = operation as? Operation {
            setupQueueDelegateForOperation(op)
            handleDependenciesForOperation(op)
            
            /*  With condition dependencies added, we can now see if this needs dependencies to enforce mutual exclusivity.
            */
            let concurrencyCategories: [String] = op.conditions.flatMap { condition in
                if !condition.dynamicType.isMutuallyExclusive { return nil }
                
                return "\(condition.dynamicType)"
            }

            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.sharedExclusivityController
                exclusivityController.addOperation(op, categories: concurrencyCategories)
                
                op.addObserver(BlockObserver { operation, _ in
                    exclusivityController.removeOperation(operation, categories: concurrencyCategories)
                })
            }
            
            /*  Indicate to the operation that we've finished our extra work on it and it's now it a state where
                it can proceed with evaluating conditions, if appropriate.
            */
            op.willEnqueue()
        } else {
            /*  For regular `NSOperation`s, we'll manually call out to the queue's delegate we don't want to just 
                capture "operation" because that would lead to the operation strongly referencing itself and that's
                the pure definition of a memory leak.
            */
            operation.addCompletionBlock { [weak self, weak operation] in
                guard let queue = self, let operation = operation else { return }
                queue.delegate?.operationQueue?(queue, operationDidFinish: operation, withErrors: [])
            }
        }
        
        delegate?.operationQueue?(self, willAddOperation: operation)
        super.addOperation(operation)   
    }
    
    func setupQueueDelegateForOperation(operation: Operation) {
        // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
        let delegate = BlockObserver(startHandler: nil,
            produceHandler: { [weak self] (operation: Operation, nsOperation: NSOperation) -> Void in
                self?.addOperation(nsOperation)
            }, finishHandler: { [weak self] (operation: Operation, errors: [NSError]) -> Void in
                if let me = self {
                    me.delegate?.operationQueue?(me, operationDidFinish: operation, withErrors: errors)
                }
            })
        operation.addObserver(delegate)
    }
    
    func handleDependenciesForOperation(operation: Operation) {
        // Extract any dependencies needed by this operation.
        let dependencies = operation.conditions.flatMap {
            $0.dependencyForOperation(operation)
        }
        
        for dependency in dependencies {
            operation.addDependency(dependency)
            
            self.addOperation(dependency)
        }
    }
    
    override public func addOperations(operations: [NSOperation], waitUntilFinished wait: Bool) {
        /*
            The base implementation of this method does not call `addOperation()`,
            so we'll call it ourselves.
        */
        for operation in operations {
            addOperation(operation)
        }
        
        if wait {
            for operation in operations {
              operation.waitUntilFinished()
            }
        }
    }
}
