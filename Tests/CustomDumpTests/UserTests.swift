

    @Test func students() {
      expectNoDifference(student1, student2)
    }















let student1 = Student(favoriteNumbers: [42, 1729], id: 1, name: "Blob")
let student2 = Student(favoriteNumbers: [42, 1729], id: 1, name: "Blob Jr")
import CustomDump
import Testing

struct Student: Equatable {
  var favoriteNumbers: [Int]
  var id: Int
  var name: String
}
