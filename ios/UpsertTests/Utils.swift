//
//  Utils.swift
//  UpsertTests
//
//  Created by Maximilian Alexander on 11/28/21.
//

import Foundation

typealias JSONDictionary = [String : Any?]

extension JSONDictionary {
    func asString() -> String {
      do {
          let data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
      } catch {
        return ""
      }
    }
}
