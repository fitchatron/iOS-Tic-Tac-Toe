//
//  ContentView.swift
//  Tic Tac Toe
//
//  Created by James Fitch on 23/05/2021.
// can make smarter using https://www.geeksforgeeks.org/minimax-algorithm-in-game-theory-set-3-tic-tac-toe-ai-finding-optimal-move/amp/

import SwiftUI

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    
    var body: some View {
        GeometryReader { geomerty in
            VStack(alignment: .leading) {
                Text("Tic Tac Toe")
                    .font(.largeTitle)
                    .bold()
                    
                Spacer()
                
                LazyVGrid(columns: viewModel.columns, spacing: 5) {
                    ForEach(0..<9) { item in
                        ZStack {
                            GameSquareView(proxy: geomerty)
                            PlayerIndicator(systemImageName: viewModel.moves[item]?.indicator ?? "")
                        }
                        .onTapGesture {
                            viewModel.processPlayerMove(item: item)
                        }
                    }
                }
                Spacer()
            }
            .disabled(viewModel.isGameBoardDisabled)
            .padding()
            .alert(item: $viewModel.alertItem) { alertitem in
                Alert(title: alertitem.title, message: alertitem.message, dismissButton: Alert.Button.default(alertitem.buttonText, action: {
                    viewModel.resetGame()
                }))
            }
        }
    }
}


struct GameSquareView: View {
    
    var proxy: GeometryProxy
    var body: some View {
        Circle()
            .foregroundColor(.red)
            .opacity(0.5)
            .frame(width: proxy.size.width / 3 - 15, height: proxy.size.width / 3 - 15)
    }
}

struct PlayerIndicator: View {
    
    let systemImageName: String
    var body: some View {
        Image(systemName: systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
    }
    
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String { player == .human ? "xmark" : "circle" }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
