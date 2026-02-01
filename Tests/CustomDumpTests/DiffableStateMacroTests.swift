//import CustomDump
//import Testing
//
//struct DiffableStateMacroTests {
//  @Test func diffableStateSnapshot() {
//    @DiffableState
//    final class Model {
//      var count: Int
//      var name: String
//      @DiffableStateIgnored var cache: Int = 0
//      var computed: Int { self.count }
//
//      init(count: Int, name: String) {
//        self.count = count
//        self.name = name
//      }
//    }
//
//    let model = Model(count: 1, name: "Blob")
//    expectNoDifference(model.diffableState, .init(count: 1, name: "Blob"))
//    expectDifference(model) {
//      model.count += 1
//      model.cache += 1
//    } changes: {
//      $0.count = 2
//    }
//  }
//}
