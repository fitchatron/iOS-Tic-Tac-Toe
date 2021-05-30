//
//  Alerts.swift
//  Tic Tac Toe
//
//  Created by James Fitch on 29/05/2021.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let buttonText: Text
}

struct AlertContext {
    static let playerWins = AlertItem(title: Text("You win!"), message: Text("You beat that super charged AI. Well done!"), buttonText: Text("Hell Yeah!"))
    static let computerWins = AlertItem(title: Text("Computer wins!"), message: Text("You sure made one super intelligent AI. We better watch out!"), buttonText: Text("Rematch"))
    static let draw = AlertItem(title: Text("Draw"), message: Text("That sure was a battle of the titans..."), buttonText: Text("Rematch"))
}
