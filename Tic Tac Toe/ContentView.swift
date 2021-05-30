//
//  ContentView.swift
//  Tic Tac Toe
//
//  Created by James Fitch on 23/05/2021.
// can make smarter using https://www.geeksforgeeks.org/minimax-algorithm-in-game-theory-set-3-tic-tac-toe-ai-finding-optimal-move/amp/

import SwiftUI

struct ContentView: View {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameBoardDisabled = false
    @State private var alertItem: AlertItem?
    
    var body: some View {
        GeometryReader { geomerty in
            VStack {
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<9) { item in
                        ZStack {
                            Circle()
                                .foregroundColor(.red)
                                .opacity(0.5)
                                .frame(width: geomerty.size.width / 3 - 15, height: geomerty.size.width / 3 - 15)
                            
                            Image(systemName: moves[item]?.indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            if (isSquareOccupied(in: moves, forIndex: item)) { return }
                            moves[item] = Move(player: .human, boardIndex: item)
                            
                            if checkWinCondition(for: .human, in: moves) {
                                alertItem = AlertContext.playerWins
                                return
                            }
                            
                            if checkForDraw(in: moves) {
                                alertItem = AlertContext.draw
                                return
                            }
                            
                            isGameBoardDisabled = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let computerPosition = determineComputerMovePosition(in: moves)
                                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                                
                                isGameBoardDisabled = false
                                
                                if checkWinCondition(for: .computer, in: moves) {
                                    alertItem = AlertContext.computerWins
                                    return
                                }
                                
                                if checkForDraw(in: moves) {
                                    alertItem = AlertContext.draw
                                    return
                                }
                                
                                
                            }
                        }
                    }
                }
                Spacer()
            }
            .disabled(isGameBoardDisabled)
            .padding()
            .alert(item: $alertItem) { alertitem in
                Alert(title: alertitem.title, message: alertitem.message, dismissButton: Alert.Button.default(alertitem.buttonText, action: {
                    resetGame()
                }))
            }
        }
    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        moves.contains(where: {$0?.boardIndex == index})
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        
        //if can win then win
        let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let computerPositions = Set(computerMoves.map{ $0.boardIndex})
        
        for pattern in winPatterns  {
            
            let winPositions = pattern.subtracting(computerPositions)
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable {
                    return winPositions.first!
                }
            }
        }
        
        //if can block then block
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        let humanPositions = Set(humanMoves.map{ $0.boardIndex})
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(humanPositions)
            
            if winPositions.count == 1 {
                let isavailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isavailable { return winPositions.first! }
            }
        }
        
        //if can take middle square, take middle square
        let centreSquare = 4
        if !isSquareOccupied(in: moves, forIndex: centreSquare) { return centreSquare }
        
        //if can't win, block, or take middle square, choose random square
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map{ $0.boardIndex})
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) { return true }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
