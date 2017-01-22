
import UIKit

struct MoveCommand {
    let direction : UISwipeGestureRecognizerDirection
    let completion : (Bool) -> ()
}
