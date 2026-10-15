import SwiftUI

struct QuizQuestion {
    let imageName: String
    let answer: String
    let options: [String]
    let fact: String
}

@main
struct WildLensArenaApp: App {
    var body: some Scene {
        WindowGroup { ArenaView() }
    }
}

struct ArenaView: View {
    @AppStorage("bestScore") private var bestScore = 0
    @State private var started = false
    @State private var finished = false
    @State private var index = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var secondsLeft = 15

    private let questions: [QuizQuestion] = [
        .init(imageName: "tv_elephant", answer: "Asian Elephant",
              options: ["Asian Elephant", "Spotted Deer", "Indian Peafowl"],
              fact: "Elephants use their trunks to explore and gather food."),
        .init(imageName: "tv_peafowl", answer: "Indian Peafowl",
              options: ["Toque Macaque", "Indian Peafowl", "Sri Lankan Leopard"],
              fact: "Peafowl are famous for their colorful display feathers."),
        .init(imageName: "tv_deer", answer: "Spotted Deer",
              options: ["Spotted Deer", "Asian Elephant", "Toque Macaque"],
              fact: "Spotted deer are also called chital."),
        .init(imageName: "tv_macaque", answer: "Toque Macaque",
              options: ["Sri Lankan Leopard", "Toque Macaque", "Spotted Deer"],
              fact: "The toque macaque is native to Sri Lanka."),
        .init(imageName: "tv_leopard", answer: "Sri Lankan Leopard",
              options: ["Sri Lankan Leopard", "Indian Peafowl", "Asian Elephant"],
              fact: "Leopards are powerful predators; observe only from a safe distance.")
    ]

    var body: some View {
        ZStack {
            // Dynamic Background: Full-screen image for start, gradient for quiz
            if !started {
                Image("tv_hero")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.1))
            } else {
                LinearGradient(colors: [Color.blue.opacity(0.2), Color.green.opacity(0.3)],
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 24) {
                if !started {
                    Text("WildLens Arena")
                        .font(.custom("Chalkboard SE", size: 120))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        // STACKED SHADOWS:
                        // The first shadow gives a wide, dark spread.
                        // The second shadow gives a sharp, dark edge right behind the text.
                        .shadow(color: .black, radius: 25, x: 0, y: 8)
                        .shadow(color: .black, radius: 4, x: 0, y: 2)
                        .padding(.bottom, 10)
                    
                    Text("Discover Sri Lankan wildlife on the big screen.")
                        .font(.custom("Chalkboard SE", size: 50))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 15, x: 0, y: 6)
                        .shadow(color: .black, radius: 3, x: 0, y: 2)
                    
                    Text("Best score: \(bestScore)")
                        .font(.custom("Chalkboard SE", size: 40))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 15, x: 0, y: 6)
                        .shadow(color: .black, radius: 3, x: 0, y: 2)
                        .padding(.top, 20)
                    
                    Button("Start wildlife quiz") { restart() }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 40)
                        .shadow(color: .black.opacity(0.6), radius: 15, x: 0, y: 6)
                        
                } else if finished {
                    Text("Quiz Complete!")
                        .font(.custom("Chalkboard SE", size: 100))
                        .fontWeight(.bold)
                    Text("Your score: \(score) / \(questions.count * 10)")
                        .font(.custom("Chalkboard SE", size: 60))
                    Text("Best score: \(bestScore)")
                        .font(.custom("Chalkboard SE", size: 40))
                    Button("Play again") { restart() }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 30)
                } else {
                    let q = questions[index]
                    Text("Question \(index + 1) / \(questions.count)")
                        .font(.custom("Chalkboard SE", size: 40))
                    HStack {
                        Text("Score: \(score)")
                        Spacer()
                        Text("Time: \(secondsLeft)s")
                    }
                    .font(.custom("Chalkboard SE", size: 35))
                    
                    Image(q.imageName)
                        .resizable().scaledToFit().frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text("Which animal is this?")
                        .font(.custom("Chalkboard SE", size: 50))
                        .fontWeight(.bold)
                    
                    HStack(spacing: 28) {
                        ForEach(q.options, id: \.self) { option in
                            Button(option) { choose(option) }
                                .buttonStyle(.borderedProminent)
                                .disabled(selectedAnswer != nil)
                        }
                    }
                    if selectedAnswer != nil {
                        Text("Correct answer: \(q.answer)")
                            .font(.custom("Chalkboard SE", size: 45))
                            .foregroundStyle(.green)
                        Text(q.fact)
                            .font(.custom("Chalkboard SE", size: 35))
                        Button(index == questions.count - 1
                               ? "Show results" : "Next animal") {
                            advance()
                        }
                    }
                }
            }
            .padding(70)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedAnswer)
        .task(id: started && !finished ? index : -1) {
            guard started && !finished else { return }
            secondsLeft = 15
            for _ in 0..<15 {
                do { try await Task.sleep(for: .seconds(1)) }
                catch { return }
                guard !Task.isCancelled && selectedAnswer == nil else { return }
                secondsLeft -= 1
                if secondsLeft == 0 {
                    selectedAnswer = "Time expired"
                    return
                }
            }
        }
    }

    private func restart() {
        score = 0; index = 0; secondsLeft = 15
        selectedAnswer = nil; finished = false; started = true
    }

    private func choose(_ answer: String) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = answer
        if answer == questions[index].answer { score += 10 }
    }

    private func advance() {
        if index == questions.count - 1 {
            finished = true
            bestScore = max(bestScore, score)
        } else {
            index += 1
            selectedAnswer = nil
        }
    }
}
