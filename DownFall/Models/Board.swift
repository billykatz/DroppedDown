//
//  Board.swift
//  DownFall
//
//  Created by William Katz on 5/12/18.
//  Copyright © 2018 William Katz LLC. All rights reserved.
//

import Foundation

class Board {
    var tiles : [[Tile]]
    var selectedTiles : [(Int, Int)]
    
    init(_ tiles: [[Tile]]) {
        self.tiles = tiles
        self.selectedTiles = []
    }
    
    func findNeighbors(_ x: Int, _ y: Int) -> [(Int, Int)] {
        //consider saving space by keep track of head of queue, then just return the whole queue
        var queue : [(Int, Int)] = [(x, y)]
        var locations : [(Int, Int)] = [(x, y)]
        
        while !queue.isEmpty {
            let (tileRow, tileCol) = queue.removeFirst()
            let tile = tiles[tileRow][tileCol]
            tile.search = .black
            //add neighbors to queue
            for i in tileRow-1...tileRow+1 {
                for j in tileCol-1...tileCol+1 {
                    if valid(neighbor: (i,j), for: (tileRow, tileCol)) {
                        //potential neighbor within bounds
//                        print("*** Valid Neighbor = \((i,j)) of tile \(tileRow, tileCol)")
                        let neighbor = tiles[i][j]
                        if neighbor.search == .white {
                            if neighbor.color == tile.color {
                                neighbor.search = .gray
                                queue.append((i,j))
//                                print("*** Enqueueing = \((i,j))")
                                locations.append((i,j))
                            }
                        }
                    }
                }
            }
        }
        resetVisited()
        selectedTiles = locations
        return locations
        
    }
    
    func valid(neighbor : (Int, Int), for tile: (Int, Int)) -> Bool {
        let (neighborRow, neighborCol) = neighbor
        let (tileRow, tileCol) = tile
//        print("Neighbor = \(neighbor)\nTile = \(tile)")
        guard neighborRow >= 0 && neighborRow < tiles.count && neighborCol >= 0 && neighborCol < tiles[neighborRow].count else {
//            print("early return, out of bounds")
            return false
        }
        let tileSum = tileRow + tileCol
        let neighborSum = neighborRow + neighborCol
        guard neighbor != tile else {
//            print("early return, same tile")
            return false
        }
        guard (tileSum % 2 == 0  && neighborSum % 2 == 1) || (tileSum % 2 == 1 && neighborSum % 2 == 0) else {
//            print("early return, differences")
            return false
        }
        return true
    }
    
    func resetVisited() {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                tiles[i][j].search = .white
            }
        }
        
        selectedTiles = []
        
    }

    
    func reset(size: Int) {
        for row in 0..<size {
            for col in 0..<size {
                tiles[row][col] = Tile.randomTile()
            }
        }
    }
    
    func shiftReplaceTiles() {
        emptyTiles()
        shiftDown()
        fillEmpty()
    }
    
    func emptyTiles() {
        for (row, col) in selectedTiles {
            tiles[row][col] = Tile.init(color: .empty)
        }
        selectedTiles = []
    }
    
    func shiftDown() {
        for col in 0..<tiles.count {
            var shift = 0
            for row in 0..<tiles[col].count {
                if tiles[row][col].color == .empty {
                    shift += 1
                } else {
                    let intermediateTile = tiles[row][col]
                    tiles[row][col] = tiles[row-shift][col]
                    tiles[row-shift][col] = intermediateTile
                }
            }
        }
    }
    
    func fillEmpty() {
        for col in 0..<tiles.count {
            for row in 0..<tiles[col].count {
                if tiles[row][col].color == .empty {
                    tiles[row][col] = Tile.randomTile()
                }
            }
        }
    }
}

extension Board {
    // class functions
    class func build(size: Int) -> Board {
        var tiles : [[Tile]] = [[]]
        
        for row in 0..<size {
            if row != 0 { tiles.append([]) }
            for _ in 0..<size {
                tiles[row].append(Tile.randomTile())
            }
        }
        
        return Board.init(tiles)
    }
}
