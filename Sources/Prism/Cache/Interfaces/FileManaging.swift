//
//  FileManaging.swift
//  Prism
//
//  Created by MinwooJe on 3/20/26.
//

import Foundation

protocol FileManaging {
    func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL]

    func contents(atPath path: String) -> Data?

    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any]

    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey : Any]?
    ) throws

    func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey : Any]?
    ) -> Bool

    func removeItem(at url: URL) throws
}

extension FileManager: FileManaging { }
