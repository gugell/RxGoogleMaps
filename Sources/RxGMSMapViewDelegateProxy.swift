//
//  RxGMSMapViewDelegateProxy.swift
//  RxGoogleMaps
//
//  Created by Yongha Yoo (inkyfox) on 2016. 10. 10..
//  Copyright © 2016년 Gen X Hippies Company. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import UIKit

public typealias RxGMSHandleTapMarker = (GMSMarkerWrapper) -> (Bool)
public typealias RxGMSHandleMarkerInfoContents = (GMSMarkerWrapper) -> (UIView?)
public typealias RxGMSHandleTapMyLocationButton = () -> (Bool)

public class RxGMSMapViewDelegateProxy
    : DelegateProxy
    , GMSMapViewDelegateWrapper
    , DelegateProxyType {
    
    var handleTapMarker: RxGMSHandleTapMarker? = nil
    var handleMarkerInfoContents: RxGMSHandleMarkerInfoContents? = nil
    var handleTapMyLocationButton: RxGMSHandleTapMyLocationButton? = nil
    
    let didTapMarkerEvent = PublishSubject<GMSMarkerWrapper>()
    let didTapMyLocationButtonEvent = PublishSubject<Void>()
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let mapView: GMSMapViewWrapper = castOrFatalError(object)
        mapView.delegateWrapper = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let mapView: GMSMapViewWrapper = castOrFatalError(object)
        return mapView.delegateWrapper
    }
    
}

// For delegates that needs return types

extension RxGMSMapViewDelegateProxy {

    public func didHandleTap(_ marker: GMSMarkerWrapper) -> Bool {
        didTapMarkerEvent.onNext(marker)
        return handleTapMarker?(marker) ?? false
    }
    
    public func markerInfoContents(marker: GMSMarkerWrapper) -> UIView? {
        return handleMarkerInfoContents?(marker)
    }

    public func didTapMyLocationButton() -> Bool {
        didTapMyLocationButtonEvent.onNext()
        return handleTapMyLocationButton?() ?? false
    }

}

// Referred from RxCococa.swift because it's not public
//   They said: workaround for Swift compiler bug, cheers compiler team :)

func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}
