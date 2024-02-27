#if canImport(SwiftData)
  import SwiftData

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  struct PersistentModelDump<T: PersistentModel>: CustomDumpReflectable {
    let wrappedValue: T

    var customDumpMirror: Mirror {
      Mirror(
        self.wrappedValue,
        children: T.schemaMetadata.map { propertyMetadata in
          let propertyMetadata = PropertyMetadata<T>(propertyMetadata)
          return (propertyMetadata.name, self.wrappedValue[keyPath: propertyMetadata.keyPath])
        },
        displayStyle: .class
      )
    }
  }

  @available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
  private struct PropertyMetadata<Root> {
    let name: String
    let keyPath: PartialKeyPath<Root>

    init(_ propertyMetadata: Schema.PropertyMetadata) {
      let children = Mirror(reflecting: propertyMetadata).children.makeIterator()
      self.name = children.next()!.value as! String
      self.keyPath = children.next()!.value as! PartialKeyPath<Root>
    }
  }
#endif
