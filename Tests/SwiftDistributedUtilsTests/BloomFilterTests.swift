import XCTest
import class Foundation.Bundle
import SwiftDistributedUtils

class BloomFilterTests : XCTestCase {
    
    private var bf: SIMDBloomFilter = SIMDBloomFilter()

    override func setUp() {
        super.setUp()
        bf = SIMDBloomFilter()
    }

    func testInitSIMDFilter() {
        XCTAssertNotNil(bf)
    }

    func testAddSingleItem() {
        bf.put(item: "hello, world")
        XCTAssert(bf.mightContain(item: "hello, world"))
        XCTAssertFalse(bf.mightContain(item: "wibble"))
    }
}
