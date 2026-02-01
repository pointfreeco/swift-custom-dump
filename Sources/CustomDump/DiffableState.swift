public protocol DiffableState<DiffableState>: AnyObject {
  associatedtype DiffableState: Equatable
  var diffableState: DiffableState { get }
}
