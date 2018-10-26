//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//


import SpriteKit


struct Transformation {
    let initial : (Int, Int)
    let end : (Int, Int)
}

typealias TileCoord = (Int, Int)

class Board {

    //  MARK: - Public
    
    /// After every move we want to check the State of the board
    /// It is possible that we have won (reached the exit)
    /// Lost, by losing health or running out of turns
    /// have no moves left
    /// or we are still playing
    /// purposely public, so that GameScene can switch on board states

    // TODO: Push new states onto top of our stack.  Undo = pop. Woo!
    private var states : [BoardState] = []
    private var _state: BoardState? {
        didSet {
            switch _state {
            case .some(let state):
                if state is UnselectedState {
                    checkGameState()
                }
            case .none:
                fatalError("This cant be")
            }
        }
    }
    
    var state: BoardState? {
        set {
            guard let newValue = newValue else { return }
            states.append(newValue)
            _state = newValue
        }
        get { return _state }
    }
    
    func handledInput(_ point: CGPoint) -> Bool {
        guard let newState = state?.handleInput(point, in: self) else { return false }
        state = newState
        return true
    }
    
    init(_ tiles: [[DFTileSpriteNode]],
         size: Int,
         playerPosition playerPos: TileCoord,
         exitPosition exitPos: TileCoord,
         buttons: [SKSpriteNode]) {
        spriteNodes = tiles
        selectedTiles = []
        newTiles = []
        boardSize = size
        playerPosition = playerPos
        exitPosition = exitPos
        self.buttons = buttons
        state = UnselectedState(currentBoard: tiles)
    }
    
    // MARK: - Notification Senders
    
    func findNeighbors(_ x: Int, _ y: Int) -> [TileCoord] {
        self.removeActions()
        resetVisited()
        var queue : [(Int, Int)] = [(x, y)]
        var head = 0
        
        while head < queue.count {
            let (tileRow, tileCol) = queue[head]
            let tileSpriteNode = spriteNodes[tileRow][tileCol]
            tileSpriteNode.search = .black
            head += 1
            //add neighbors to queue
            for i in tileRow-1...tileRow+1 {
                for j in tileCol-1...tileCol+1 {
                    if valid(neighbor: (i,j), for: (tileRow, tileCol)) {
                        //potential neighbor within bounds
                        let neighbor = spriteNodes[i][j]
                        if neighbor.search == .white {
                            if neighbor == tileSpriteNode {
                                neighbor.search = .gray
                                queue.append((i,j))
                            }
                        }
                    }
                }
            }
        }
        selectedTiles = queue
        if queue.count >= 3 {
            let note = Notification.init(name: .neighborsFound, object: nil, userInfo: ["tiles":selectedTiles])
            NotificationCenter.default.post(note)
        }
        
        return queue
    }
    
    
    /*
     * Remove and refill selected tiles from the current board
     *
     *  - replaces each selected tile with an Empty sprite placeholder
     *  - loops through each column starting an at row 0 and increments a shift counter when it encounters an Empty sprite placeholder
     *  - updates the board store [[DFTileSpriteNdes]]
     *  - sends Notification with three dictionarys, removed tiles, new tiles, and which have shifted down
    */

    func removeAndRefill(selectedTiles: [TileCoord]) -> [[DFTileSpriteNode]] {
        for (row, col) in selectedTiles {
            spriteNodes[row][col] = DFTileSpriteNode.init(type: .empty)
        }

        
        var shiftDown : [Transformation] = []
        var newTiles : [Transformation] = []
        for col in 0..<boardSize {
            var shift = 0
            for row in 0..<boardSize {
                switch spriteNodes[row][col].type {
                case .empty:
                    shift += 1
                default:
                    if shift != 0 {
                        let endRow = row-shift
                        let endCol = col
                        if spriteNodes[row][col].type == .player {
                            playerPosition = (endRow, endCol)
                        } else if spriteNodes[row][col].type == .exit {
                            exitPosition = (endRow, endCol)
                        }
                        let trans = Transformation.init(initial: (row, col), end: (endRow, endCol))
                        shiftDown.append(trans)

                        //update sprite storage
                        let intermediateTile = spriteNodes[row][col]
                        spriteNodes[row][col] = spriteNodes[row-shift][col]
                        spriteNodes[row-shift][col] = intermediateTile
                    }
                }
            }
            
            //create new tiles here as we know the most we can about the columns
            for shiftIdx in 0..<shift {
                let startRow = boardSize + shiftIdx
                let startCol = col
                let endRow = boardSize - shiftIdx - 1
                let endCol = col
                
                //update sprite storage
                //remove empty one
                spriteNodes[endRow][endCol].removeFromParent()
                //add random one
                spriteNodes[endRow][endCol] = DFTileSpriteNode.randomRock()
                
                //append to shift dictionary
                var trans = Transformation.init(initial: (startRow, startCol),
                                                end: (endRow, endCol))
                shiftDown.append(trans)
                
                //update new tiles
                trans = Transformation.init(initial: (startRow, startCol),
                                            end: (endRow, endCol))
                newTiles.append(trans)
            }
        }
        
        //build notification dictionary
        let newBoardDictionary = ["removed": selectedTiles,
                                  "newTiles": newTiles,
                                  "shiftDown": shiftDown] as [String : Any]
        NotificationCenter.default.post(name: .computeNewBoard, object: nil, userInfo: newBoardDictionary)
        
        return spriteNodes
    }
    
    //  MARK: - Private

    private(set) var buttons: [SKSpriteNode]
    private(set) var spriteNodes : [[DFTileSpriteNode]]
    private var selectedTiles : [(Int, Int)]
    private var newTiles : [(Int, Int)]
    
    private(set) var boardSize: Int = 0
    
    private var tileSize = 75
    
    private var playerPosition : TileCoord
    private var exitPosition : TileCoord

    private func valid(neighbor : (Int, Int), for DFTileSpriteNode: (Int, Int)) -> Bool {
        let (neighborRow, neighborCol) = neighbor
        let (tileRow, tileCol) = DFTileSpriteNode
        guard neighborRow >= 0 && neighborRow < boardSize && neighborCol >= 0 && neighborCol < spriteNodes[neighborRow].count else {
            return false
        }
        let tileSum = tileRow + tileCol
        let neighborSum = neighborRow + neighborCol
        guard neighbor != DFTileSpriteNode else { return false }
        guard (tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0) else { return false }
        return true
    }
    
    private func resetVisited() {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                spriteNodes[row][col].search = .white
            }
        }
        
    }
    
    private func removeActions(_ completion: (()-> Void)? = nil) {
        for i in 0..<boardSize {
            for j in 0..<spriteNodes[i].count {
                spriteNodes[i][j].removeAllActions()
                spriteNodes[i][j].run(SKAction.fadeIn(withDuration: 0.2)) {
                    completion?()
                }
            }
        }
    }
}

extension Board {
    
    // MARK: - Public API
    
    func blinkTiles(at locations: [(Int, Int)]) {
        let blinkOff = SKAction.fadeOut(withDuration: 0.2)
        let blinkOn = SKAction.fadeIn(withDuration: 0.2)
        let blink = SKAction.repeatForever(SKAction.sequence([blinkOn, blinkOff]))
        
        for locale in locations {
            spriteNodes[locale.0][locale.1].run(blink)
        }
    }

}

//MARK: - Factory
extension Board {

    class func build(size: Int, playerPosition: TileCoord? = nil, exitPosition: TileCoord? = nil) -> Board {
        var tiles : [[DFTileSpriteNode]] = []
        for row in 0..<size {
            tiles.append([])
            for _ in 0..<size {
                tiles[row].append(DFTileSpriteNode.randomRock())
            }
        }
        let playerRow: Int
        let playerCol: Int
        if let playerPos = playerPosition {
            playerRow = playerPos.0
            playerCol = playerPos.1
        } else {
            playerRow = Int.random(size)
            playerCol = Int.random(size)
        }
        tiles[playerRow][playerCol] = DFTileSpriteNode.init(type: .player)
        
        let exitRow: Int
        let exitCol: Int
        if let exitPos = exitPosition {
            exitRow = exitPos.0
            exitCol = exitPos.0
        } else {
            exitRow = Int.random(size, not: playerRow)
            exitCol = Int.random(size, not: playerCol)
        }
        tiles[exitRow][exitCol] = DFTileSpriteNode.init(type: .exit)
        
        // create left and right buttons
        let leftButton = SKSpriteNode.init(texture: SKTexture(imageNamed: "rotateLeft"))
        leftButton.name = "leftRotate"
        let rightButton = SKSpriteNode.init(texture: SKTexture(imageNamed: "rotateRight"))
        rightButton.name = "rightRotate"
        let buttons = [leftButton, rightButton]
        
        return Board.init(tiles,
                          size: size,
                          playerPosition: (playerRow, playerCol),
                          exitPosition: (exitRow, exitCol),
                          buttons: buttons)
    }
    
    
    /*
     Only to be used by settings button.  This is a quick reset for debugging purposes
     */
    func resetNoMoreMoves() -> Board {
        return Board.build(size: boardSize, playerPosition: playerPosition, exitPosition: exitPosition)
    }
}

// MARK: - Rotation

extension Board {
    
    enum Direction {
        case left
        case right
    }
    
    func rotate(_ direction: Direction) -> [[DFTileSpriteNode]] {
        self.resetVisited()
        self.removeActions()
        var transformation : [Transformation] = []
        var intermediateBoard : [[DFTileSpriteNode]] = []
        switch direction {
        case .left:
            let numCols = boardSize - 1
            for colIdx in 0..<boardSize {
                var count = 0
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<boardSize {
                    let endRow = colIdx
                    let endCol = numCols - count
                    if spriteNodes[rowIdx][colIdx].type == .player {
                        playerPosition = (endRow, endCol)
                    } else if spriteNodes[rowIdx][colIdx].type == .exit {
                        exitPosition = (endRow, endCol)
                    }
                    column.insert(spriteNodes[rowIdx][colIdx], at: 0)
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (endRow, endCol))
                    transformation.append(trans)
                    count += 1
                }
                intermediateBoard.append(column)
            }
            spriteNodes = intermediateBoard
        case .right:
            let numCols = boardSize - 1
            for colIdx in (0..<boardSize).reversed() {
                var column : [DFTileSpriteNode] = []
                for rowIdx in 0..<boardSize {
                    let endRow = numCols - colIdx
                    let endCol = rowIdx
                    if spriteNodes[rowIdx][colIdx].type == .player {
                        playerPosition = (endRow, endCol)
                    } else if spriteNodes[rowIdx][colIdx].type == .exit {
                        exitPosition = (endRow, endCol)
                    }
                    column.append(spriteNodes[rowIdx][colIdx])
                    let trans = Transformation.init(initial: (rowIdx, colIdx), end: (endRow, endCol))
                    transformation.append(trans)
                }
                intermediateBoard.append(column)
            }
            spriteNodes = intermediateBoard
        }
        NotificationCenter.default.post(name: .rotated, object: nil, userInfo: ["transformation": transformation])
        return intermediateBoard
    }

    func shouldRotateDirection(point: CGPoint) -> Direction? {
        for button in buttons {
            if button.contains(point) {
                switch button.name {
                case "leftRotate":
                    return .left
                case "rightRotate":
                    return .right
                case .none:
                    return nil
                case .some(_):
                    return nil
                }
            }
        }
        return nil
    }
}


//MARK: - Check Board Game State

extension Board {
    func checkGameState() {
        if checkWinCondition() {
            //send game win notification
            let trans = Transformation(initial: playerPosition, end: exitPosition)
            NotificationCenter.default.post(name: .gameWin, object: nil, userInfo: ["transformation": [trans]])
        } else if !boardHasMoreMoves() {
            //send no more moves notification
            NotificationCenter.default.post(name: .noMovesLeft, object: nil)
        }
    }
    
    private func checkWinCondition() -> Bool {
        let (playerRow, playerCol) = playerPosition
        let (exitRow, exitCol) = exitPosition
        return playerRow == exitRow + 1 && playerCol == exitCol
    }
    
    private func dfs() -> [TileCoord]? {
        
        func similarNeighborsOf(coords: TileCoord) -> [TileCoord] {
            var neighborCoords: [TileCoord] = []
            let currentNode = spriteNodes[coords.0][coords.1]
            for i in coords.0-1...coords.0+1 {
                for j in coords.1-1...coords.1+1 {
                    guard valid(neighbor: (i,j), for: (coords.0, coords.1)) else { continue }
                    let neighbor = spriteNodes[i][j]
                    if neighbor.search == .white && neighbor == currentNode {
                        //only add neighbors that are in a cardinal direction, not out of bounds, haven't been searched and re the same as the currentNode
                        neighborCoords.append((i, j))
                    }
                }
            }
            return neighborCoords
        }
        
        defer { resetVisited() } // reset the visited nodes so we dont desync the store and UI
        
        for index in 0..<spriteNodes.reduce([],+).count {
            let row = index / boardSize // get the row
            let col = (index - row * boardSize) % boardSize // get the column
            resetVisited()
            var queue : [(Int, Int)] = [(row, col)]
            var head = 0
            while head < queue.count {
                guard queue.count < 3 else { return queue } // once neighbors is more than 3, then we know that the original tile + these two neighbors means there is a legal move left
                let (tileRow, tileCol) = queue[head]
                let tileSpriteNode = spriteNodes[tileRow][tileCol]
                tileSpriteNode.search = .black
                head += 1
                //add neighbors to queue
                for (i, j) in similarNeighborsOf(coords: (tileRow, tileCol)) {
                    spriteNodes[i][j].search = .gray
                    queue.append((i,j))
                }
                if queue.count >= 3 { return queue }
            }
        }
        return nil
    }
    
    private func boardHasMoreMoves() -> Bool {
        let count = dfs()?.count ?? 0
        return count > 2
    }
}


//MARK: - Getters for private instance members

extension Board {
    
    func getTileSize() -> Int {
        return self.tileSize
    }
}
