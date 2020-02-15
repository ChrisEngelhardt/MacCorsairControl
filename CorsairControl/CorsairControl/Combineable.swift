//
//  Combineable.swift
//  test
//
//  Created by Chris Engelhardt on 21.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import Combine

public struct Combineable<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has Combineable extensions.
public protocol CombineCompatible {
    /// Extended type
    associatedtype CompatibleType

    /// Combineable extensions.
    static var combine: Combineable<CompatibleType>.Type { get set }

    /// Combineable extensions.
    var combine: Combineable<CompatibleType> { get set }
}

extension CombineCompatible {
    /// Combineable extensions.
    public static var combine: Combineable<Self>.Type {
        get {
            return Combineable<Self>.self
        }
        set {
            // this enables using Combineable to "mutate" base type
        }
    }

    /// Combineable extensions.
    public var combine: Combineable<Self> {
        get {
            return Combineable(self)
        }
        set {
            // this enables using Combineable to "mutate" base object
        }
    }
}

import class Foundation.NSObject

/// Extend NSObject with `combine` proxy.
extension NSObject: CombineCompatible { }
extension Corsair: CombineCompatible { }
