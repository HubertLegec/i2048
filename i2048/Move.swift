
enum Move {
    case singleMove(source : Int, destination: Int, value: Int, wasMerged : Bool)
    case doubleMove(source1 : Int, source2 : Int, destination : Int, value: Int)
}
