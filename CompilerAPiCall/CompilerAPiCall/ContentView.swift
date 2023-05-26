//
//  ContentView.swift
//  CompilerAPiCall
//
//  Created by a mystic on 2023/03/04.
//

import SwiftUI

struct ContentView: View {
    @State private var resultText = ""
    @State private var resultTextStack = ""
    @State private var command = ""
    @State private var isFetching = false
    @State private var showResult = false
    @State private var resultOpacity = false
    
    var body: some View {
        ZStack {
            VStack {
                TextEditor(text: $command)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .frame(width: 300, height: 400)
                    .shadow(radius: 10)
                Spacer().frame(height: 35)
                compileButton
            }
            ProgressView().opacity(isFetching ? 1 : 0)
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showResult) {
            compileResults
                .opacity(resultOpacity ? 1 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.5)) {
                        resultOpacity = true
                    }
                }
                .onDisappear {
                    resultOpacity = false
                    failure = false
                    success = false
                }
        }
    }
    
    var compileButton: some View {
        Button {
            fetchCompileResult(command)
        } label: {
            Label("Compile", systemImage: "paperplane.fill")
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black))
        }
    }
    
    @State private var success = false
    @State private var failure = false
    
    var compileResults: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if success {
                        LottieView(jsonName: "bear")
                            .frame(width: 200, height: 200)
                    }
                    ZStack {
                        VStack(spacing: 4) {
                            Text(resultTextStack)
                                .padding()
                                .font(.footnote)
                                .background(RoundedRectangle(cornerRadius: 7).foregroundColor(.black).opacity(0.8))
                                .padding()
                            Text(resultText)
                                .padding()
                                .font(.title)
                                .background(RoundedRectangle(cornerRadius: 7).foregroundColor(resultText == "good code" ? .orange : .gray).opacity(0.7))
                        }
                        if failure {
                            LottieView(jsonName: "wrong", loopMode: .repeat(3)).frame(width: 400, height: 400)
                        }
                        if success {
                            LottieView(jsonName: "congratulations", loopMode: .repeat(3)).frame(width: 400, height: 400)
                        }
                    }
                }
                .foregroundColor(.white)
                .opacity(resultTextStack != "" ? 1 : 0)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            showResult = false
                        }
                    }
                }
            }.padding()
        }.edgesIgnoringSafeArea(.all)
    }
    
    private func fetchCompileResult(_ command: String) {
        isFetching = true
        if let command = command.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "your url" + "/?command=" + command
            Task {
                let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
                let decodedResponse = try? JSONDecoder().decode(CompileResult.self, from: data)
                if let resultOfAsem = decodedResponse?.compileResult, let stackResult = decodedResponse?.stackSimResult {
                    if resultOfAsem.contains("bad code") {
                        resultText = "bad code"
                    } else {
                        resultText = "good code"
                    }
                    resultTextStack = stackResult
                    if (resultText.contains("error") || resultTextStack.contains("error")) {
                        failure = true
                        success = false
                        resultText = "bad code"
                    } else {
                        failure = false
                        success = true
                    }
                }
                isFetching = false
                showResult = true
            }
        }
    }
}

struct CompileResult: Codable {
    let compileResult: String
    let stackSimResult: String
}


