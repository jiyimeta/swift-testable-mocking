extension Array {
    func mapLast(_ transform: (Element) throws -> Element) rethrows -> Self {
        guard count > 0 else {
            return self
        }

        var array = Array(self)

        array[array.count - 1] = try transform(array[array.count - 1])

        return array
    }

    func appending(_ newElement: Element) -> Self {
        var array = Array(self)

        array.append(newElement)

        return array
    }
}

extension Array where Element: Hashable {
    func duplicateElements() -> Set<Element> {
        var duplicates: Set<Element> = []

        for i in 0 ..< count {
            for j in i + 1 ..< count {
                guard self[i] == self[j] else { continue }

                duplicates.insert(self[i])
                break
            }
        }

        return duplicates
    }
}
