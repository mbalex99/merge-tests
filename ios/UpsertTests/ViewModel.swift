//
//  ViewModel.swift
//  UpsertTests
//
//  Created by Maximilian Alexander on 11/28/21.
//
import SwiftUI
import DittoSwift
import Combine
import CombineDitto

struct Action: Identifiable {
    var id: Int
    var text: String
}


class ViewModel: ObservableObject {

    @Published var collectionName: String = "cars"
    @Published var docID: String = "123abc"
    @Published var currentDocJSONString = "null"
    @Published var actions = [Action]()

    var cancellables = Set<AnyCancellable>()

    let ditto: Ditto = DittoManager.shared.ditto

    var lastActionId = 0

    init() {
        setLiveQuery()
    }

    func setLiveQuery() {
        cancellables.removeAll()
        ditto.store.collection(collectionName).findByID(docID)
            .publisher()
            .map({ $0.document?.value.asString() ?? "null" })
            .assign(to: \.currentDocJSONString, on: self)
            .store(in: &cancellables)
    }

    func insert() {
        print("insert called")
        let payload: [String: Any?] = [
            "_id": docID,
            "name": "Honda-overwritten-\(Int.random(in: 0..<999))",
            "isSold": true,

            "tags": ["a", "b-overwritten-\(Int.random(in: 0..<999))", "c"]
        ]
        try! ditto.store.collection(collectionName)
            .insert(payload)
        lastActionId = lastActionId + 1
        actions.insert(Action(id: lastActionId, text: ".insert(\(payload.asString())"), at: 0)
    }

    func insertOverwrite() {
        print("insertOverwrite called")
        let payload: [String: Any?] = [
            "_id": docID,
            "name": "Honda-overwritten-\(Int.random(in: 0..<999))",
            "isSold": true,
            "newPropertyOverwitten": Int.random(in: 0..<999),
            "tags": ["a", "b", "c"]
        ]
        try! ditto.store.collection(collectionName)
            .insert(payload)
        lastActionId = lastActionId + 1
        actions.insert(Action(id: lastActionId, text: ".insert(\(payload.asString())"), at: 0)
    }

    func insertMerge() {
        print("insertMerge called")
        let payload: [String: Any?] = [
            "_id": docID,
            "name": "Honda",
            "isSold": true,
            "tags": ["a", "b-merge-overwritten-\(Int.random(in: 0..<999))", "c", "new-\(Int.random(in: 0..<999))"]
        ]
        try! ditto.store.collection(collectionName)
            .insertWithStrategy(payload, writeStrategy: .merge)
        lastActionId = lastActionId + 1
        actions.insert(Action(id: lastActionId, text: ".insert(\(payload.asString())"), at: 0)
    }

    func remove() {
        print("remove called")
        ditto.store.collection(collectionName).findByID(docID).remove()
        lastActionId = lastActionId + 1
        actions.insert(Action(id: lastActionId, text: ".remove()"), at: 0)
    }

}
