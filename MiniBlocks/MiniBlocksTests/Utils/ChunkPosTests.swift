import XCTest
@testable import MiniBlocks

class ChunkPosTests: XCTestCase {
    func testChunkPosContaining() {
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 0, z: 0)), ChunkPos(x: 0, z: 0))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 15, z: 0)), ChunkPos(x: 0, z: 0))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 15, z: 15)), ChunkPos(x: 0, z: 0))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 16, z: 15)), ChunkPos(x: 1, z: 0))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 16, z: -1)), ChunkPos(x: 1, z: -1))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 16, z: -16)), ChunkPos(x: 1, z: -1))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 16, z: -17)), ChunkPos(x: 1, z: -2))
        XCTAssertEqual(ChunkPos(containing: BlockPos2(x: 16, z: -32)), ChunkPos(x: 1, z: -2))
    }
}
