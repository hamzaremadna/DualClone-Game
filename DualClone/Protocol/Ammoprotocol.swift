
typealias DidRunOutOfAmmoEventHandler = (_ object: AnyObject) -> ()

protocol Ammoprotocol {
    var ammonumber: Int { get set }
    var didRunOutOfAmmoEventHandler: DidRunOutOfAmmoEventHandler? { get set }
}
