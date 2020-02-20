import Foundation

let ch = ConsistentHashRing()

ch.addNode("node0")

let t = BinaryTree<Int>()

func printTime() {
    let currentDateTime = Date()
    print("\(currentDateTime)")
}

let bf = NaiveBloomFilter()

printTime()

for _ in 0...100000000 {
    bf.put(item: "hi")
}

printTime()

//print("\(bf.mightContain(item: "hi"))")
//print("\(bf.mightContain(item: "wibble"))")

let sbf = SIMDBloomFilter()

for _ in 0...100000000 {
    sbf.put(item: "hi")
}
printTime()

print("\(sbf.mightContain(item: "hi"))")
print("\(sbf.mightContain(item: "wibble"))")
