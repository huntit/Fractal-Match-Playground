import Foundation

public struct Array2D<T> {
    public let columns: Int
    public let rows: Int
    fileprivate var array: [T]
    
    public init(columns: Int, rows: Int, initialValue: T) {
        self.columns = columns
        self.rows = rows
        array = .init(repeating: initialValue, count: rows*columns)
    }
    
    public subscript(column: Int, row: Int) -> T {
        get {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            return array[row*columns + column]
        }
        set {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            array[row*columns + column] = newValue
        }
    }
}



enum FracType: UInt32, CustomStringConvertible {
    case frac03, frac12, frac02, frac023, frac1, frac13
    var description: String {
        switch self {
        case .frac03: return "--\\--"
        case .frac12: return "--/--"
        case .frac02: return "-|---"
        case .frac023: return "--L--"
        case .frac1: return "---'-"
        case .frac13: return "---|-"
        default: return ""
        }
    }
    static func random() -> FracType {
        return FracType(rawValue: arc4random_uniform(frac13.rawValue + 1))!
    }
    //TODO: random fractype func
}


struct Frac {
    var type: FracType
    var board: Board?  // parent board
    var matched: Bool = false
    
    static func random() -> Frac {
        return Frac(type: FracType.random(), board: nil, matched: false)
    }
    /*
    mutating func setMatched(_ value: Bool) {
        matched = value
    }
    func match() {
        if type == .frac02 {
            
        }
 }
 */
}

extension Frac: CustomStringConvertible {
    var description: String {
        let matchedSymbol: String = matched ? "*" : " "
        return type.description + matchedSymbol
    }
}
 
class Board {
    let cols = 8
    let rows = 8
    var grid = Array2D<Frac?>(columns: 8, rows: 8, initialValue: nil)
    
    init() {
        // fill the board with random fracs
        for y in 0 ..< rows {
            for x in 0 ..< cols {
                var randomFrac = Frac.random()
                randomFrac.board = self
                grid[x,y] = randomFrac
            }
        }
    }
    
    func description() -> String {
        var boardDescription: String = "\n"
        for x in 0 ..< cols {
            boardDescription += " --\(x)-- "
        }
        boardDescription += " ----- \n"
        
        for y in 0 ..< rows {
            for x in 0 ..< cols {
                if let frac = grid[x,y] {
                    boardDescription += "\(frac) "
                } else {
                    boardDescription += "     "
                }
            }
            boardDescription += " --- \(y)\n"
        }
        return boardDescription
    }
    
    func findMatches() {
        for y in 0 ..< rows {
            for x in 0 ..< cols {
                if let frac = grid[x,y] {
                    // |- and -| fracs above another one
                    if [FracType.frac02, FracType.frac13].contains(frac.type) {
                        if isValid(x, y+1) {
                            if let otherFrac = grid[x,y+1] {
                                if otherFrac.type == frac.type {
                                    grid[x,y] = Frac(type: frac.type, board: nil, matched: true)
                                    grid[x,y+1] = Frac(type: frac.type, board: nil, matched: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isValid(_ x:Int, _ y:Int)-> Bool {
        if x >= 0 && x < cols && y >= 0 && y < rows {
            return true
        }
        return false
    }
    
}


let board = Board()
print("board[2,3] = \(board.grid[2,3])")
print("board = \(board.description())")
board.findMatches()
print("board = \(board.description())")



