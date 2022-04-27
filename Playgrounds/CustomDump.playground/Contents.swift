import CustomDump
import Foundation

struct User {
  var favoriteNumbers: [Int]
  var id: Int
  var name: String
}

var user = User(
  favoriteNumbers: [42, 1729],
  id: 2,
  name: "Blob"
)

var users = (1...5).map {
  User(
    favoriteNumbers: [$0],
    id: $0,
    name: "Blob \($0)"
  )
}

var other = users
other.append(
  .init(
    favoriteNumbers: [42, 1729],
    id: 100,
    name: "Blob Sr."
  )
)

print(diff(users, other)!)

struct MyError: Error {
  var id = 1
  var message = "asdf"
}

let error: Error = NSError(
  domain: "co.pointfree",
  code: 42,
  userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]
)
customDump(error)
dump(error)
