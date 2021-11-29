//
//  ContentView.swift
//  UpsertTests
//
//  Created by Maximilian Alexander on 11/28/21.
//

import SwiftUI
import DittoSwift
import CombineDitto

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Form {
                    VStack(alignment: .leading) {
                        Text("Collection Name")
                            .font(.caption2)
                        TextField("collectionName", text: $viewModel.collectionName, prompt: Text("Collection Name"))
                            
                    }
                    VStack(alignment: .leading) {
                        Text("DocID")
                            .font(.caption2)
                        TextField("docID", text: $viewModel.docID, prompt: Text("Collection Name"))
                    }
                    HStack {
                        Button("insert", action: { viewModel.insert() })
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                        Button("remove", action: { viewModel.remove() })
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    HStack {
                        Button("insert(.overwrite)", action: { viewModel.insertOverwrite() })
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .foregroundColor(.black)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                        Button("insert(.merge)", action: { viewModel.insertMerge() })
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .foregroundColor(.black)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(maxHeight: 300)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current Document \(viewModel.docID)")
                            .font(Font.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 10 : 14).monospaced())
                        Text(viewModel.currentDocJSONString)
                            .font(Font.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 10 : 14).monospaced())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .frame(width: geometry.size.width,
                                   height: nil,
                                   alignment: .topLeading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPad Pro (11-inch) (3rd generation)")
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .previewInterfaceOrientation(.landscapeRight)
        }
    }
}
