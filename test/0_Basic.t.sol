pragma solidity ^0.8.17;

import "forge-std/Test.sol";

contract A {
    constructor() {}
}

contract BasicTest is Test {
    uint256 testNumber;

    A a;

    function setUp() public {
        console2.log("setUp is equivalent to `beforeEach`");
        console2.log("We can setup any state we need to");

        a = new A();

        testNumber = 42;
    }

    function testNumberIs42() public {
        assertEq(testNumber, 42);
    }

    // forge test --match-test testFail_PleaseDontUseThis
    function testFail_PleaseDontUseThis() public {
        console2.log("`testFail` is an anti-pattern. Use vm.expectRevert instead.");
        assertTrue(false);
    }
}
