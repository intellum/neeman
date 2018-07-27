//
//  NetworkError.swift
//  Pods
//
//  Created by Stephen Williams on 23/02/16.
//
//

import UIKit

/**
 Describes an error that occured during network communications. 
 */
public enum NetworkError: Error, CustomStringConvertible {
    /// Unknown or not supported error.
    case Unknown
    
    /// Not connected to the internet.
    case NotConnectedToInternet
    
    /// International data roaming turned off.
    case InternationalRoamingOff
    
    /// Cannot reach the server.
    case NotReachedServer
    
    /// Connection is lost.
    case ConnectionLost
    
    /// Incorrect data returned from the server.
    case IncorrectDataReturned

    /**
        The following errors fall through to .Unknown
        NSURLErrorUnknown, NSURLErrorCancelled, NSURLErrorHTTPTooManyRedirects, NSURLErrorUserCancelledAuthentication,
        NSURLErrorUserAuthenticationRequired, NSURLErrorNoPermissionsToReadFile, NSURLErrorSecureConnectionFailed,
        NSURLErrorServerCertificateHasBadDate, NSURLErrorCallIsActive, NSURLErrorDataNotAllowed, NSURLErrorRequestBodyStreamExhausted,
        NSURLErrorServerCertificateUntrusted, NSURLErrorServerCertificateHasUnknownRoot, NSURLErrorServerCertificateNotYetValid,
        NSURLErrorClientCertificateRejected, NSURLErrorClientCertificateRequired, NSURLErrorCannotLoadFromNetwork,
        NSURLErrorCannotCreateFile, NSURLErrorCannotOpenFile, NSURLErrorCannotCloseFile,
        NSURLErrorCannotWriteToFile, NSURLErrorCannotRemoveFile, NSURLErrorCannotMoveFile,
        NSURLErrorDownloadDecodingFailedMidStream, NSURLErrorDownloadDecodingFailedToComplete
     
     - parameter error: The NSError we should make the NetworkError from.
    */
    public init(error: NSError) {
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorBadURL:
                self = .IncorrectDataReturned // Because it is caused by a bad URL returned in a JSON response from the server.
            case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                self = .NotReachedServer
            case NSURLErrorUnsupportedURL, NSURLErrorNetworkConnectionLost:
                self = .IncorrectDataReturned
            case NSURLErrorDataLengthExceedsMaximum:
                self = .ConnectionLost
            case NSURLErrorDNSLookupFailed:
                self = .NotReachedServer
            case NSURLErrorNotConnectedToInternet:
                self = .NotConnectedToInternet
            case NSURLErrorResourceUnavailable, NSURLErrorRedirectToNonExistentLocation, NSURLErrorBadServerResponse,
                    NSURLErrorZeroByteResource, NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData,
                    NSURLErrorCannotParseResponse, NSURLErrorFileDoesNotExist, NSURLErrorFileIsDirectory:
                self = .IncorrectDataReturned
            case NSURLErrorInternationalRoamingOff:
                self = .InternationalRoamingOff
            default:
                self = .Unknown
            }
        } else {
            self = .Unknown
        }
    }
    /**
     A localized description of the NetworkError.
     */
    public var description: String {
        let text: String
        switch self {
        case .Unknown:
            text = NeemanLocalizedString("NetworkError_Unknown", comment: "Error description")
        case .NotConnectedToInternet:
            text = NeemanLocalizedString("NetworkError_NotConnectedToInternet", comment: "Error description")
        case .InternationalRoamingOff:
            text = NeemanLocalizedString("NetworkError_InternationalRoamingOff", comment: "Error description")
        case .NotReachedServer:
            text = NeemanLocalizedString("NetworkError_NotReachedServer", comment: "Error description")
        case .ConnectionLost:
            text = NeemanLocalizedString("NetworkError_ConnectionLost", comment: "Error description")
        case .IncorrectDataReturned:
            text = NeemanLocalizedString("NetworkError_IncorrectDataReturned", comment: "Error description")
        }
        return text
    }
}
