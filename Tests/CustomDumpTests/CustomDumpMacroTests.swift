import CustomDump
import Testing

struct CustomDumpMacroTests {
  @Test func snapshot() {
    let model = Model(count: 1, name: "Blob")
    expectNoDifference(model.customDumpValue, Model.CustomDumpValue(count: 1, name: "Blob"))
    expectDifference(model) {
      model.incrementButtonTapped()
    } changes: {
      $0.count = 2
    }
    #expect(model.cache == 2)
  }
}

@CustomDump
public final class Model {
  var count: Int {
    didSet {
      cache = count
    }
  }
  var name: String
  @CustomDumpIgnored var cache: Int = 0
  var computed: Int { count }

  init(count: Int, name: String) {
    self.count = count
    self.cache = count
    self.name = name
  }

  func incrementButtonTapped() {
    count += 1
  }
}
