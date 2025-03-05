//
//  ContentView.swift
//  BoggletV2
//
//  Created by HPro2 on 2/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var words = [String]()
    @State private var guessedWords = [String]()
    @State private var startingWord = ""
    @State private var guess = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            Spacer()
            Spacer()
            VStack(alignment: .center, spacing: CGFloat(20)) {
                Text("Your word: \(startingWord)")
                    .bold()
            }
            List {
                Section {
                    TextField("Enter your word", text: $guess)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.alphabet)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                Section {
                    ForEach(guessedWords, id: \.self) {
                        word in
                        HStack {
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("Bogglet")
            .onSubmit(makeGuess)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        
        Section {
            Text("Score: \(score)")
                .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("New Game", action: newGame)
            }
        }
    }
    
    func makeGuess() {
        let answer = guess.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard real(guess: answer) else {
            wordError(title: "Invalid Word", message: "Please enter a valid word.")
            return
        }
        guard original(guess: answer) else {
            wordError(title: "Unoriginal Word", message: "Please enter a word that has not been guessed yet.")
            return
        }
        guard possible(guess: answer) else {
            wordError(title: "Impossible Word", message: "Please enter a word that contains only letters from the given word.")
            return
        }
        
        withAnimation {
            guessedWords.insert(answer, at: 0)
        }
        score += answer.count
        guess = ""
    }
    
    func startGame() {
        if let filePath = Bundle.main.path(forResource: "words", ofType: "txt") {
            if let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) {
                words = fileContents.components(separatedBy: "\n")
                newGame()
                return
            }
        }
        fatalError("Could not load the file.")
    }
    
    func newGame() {
        guessedWords.removeAll()
        startingWord = words.randomElement() ?? "succeeds"
        score = 0
    }
    
    func real(guess: String) -> Bool {
        if guess.count == 1 {
            if guess == "i" || guess == "a" {
                return true
            } else {
                return false
            }
        }
        let textChecker = UITextChecker()
        let range = NSMakeRange(0, guess.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: guess, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func original(guess: String) -> Bool {
        return !guessedWords.contains(guess)
    }
    
    func possible(guess: String) -> Bool {
        var letters: [String] = []
        for char in startingWord {
            letters.append(String(char))
        }
        
        for char in guess {
            if letters.contains(String(char)) {
                for index in 0..<letters.count {
                    if letters[index] == String(char) {
                        letters.remove(at: index)
                        break
                    }
                }
            } else {
                return false
            }
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
