//
//  GameViewModel.swift
//  Tic Tac Toe
//
//  Created by James Fitch on 31/05/2021.
//

import SwiftUI

final class GameViewModel: ObservableObject {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameBoardDisabled = false
    @Published var alertItem: AlertItem?
    
    let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
    
    func processPlayerMove(item: Int) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
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
    
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        moves.contains(where: {$0?.boardIndex == index})
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        
        //if can win then win
        let winPosition = checkWinOrBlockPosition(player: .computer)
        if winPosition != nil { return winPosition! }
        
        //if can block then block
        let blockPosition = checkWinOrBlockPosition(player: .human)
        if blockPosition != nil { return blockPosition! }
        
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
    
    func checkWinOrBlockPosition(player: Player) -> Int? {
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == player }
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
        return nil
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        
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
