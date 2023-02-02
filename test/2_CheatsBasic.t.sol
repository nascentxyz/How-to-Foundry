pragma solidity ^0.8.17;

import "forge-std/Test.sol";

contract Tester {

    address bob;
    constructor(address _bob) {
        bob = _bob;
    }

    function revertsIfZero(uint256 a) public {
        require(a > 0);
    }

    function onlyBob() public {
        require(msg.sender == bob);
    }

    function onlyBobEOA() public {
        require(msg.sender == bob);
        require(tx.origin == bob);
    }
}

contract CheatsTest is Test {
    Tester test;

    address bob;
    function setUp() public {
        console2.log("makeAddr creates a new address and labels the address for traces");
        bob = makeAddr("bob");

        test = new Tester(bob);
    }

    // forge test --match-test test_vmExists
    function test_vmExists() public {
        console2.log("Inheriting `Test` from forge-std gives us access to `vm`");
        console2.log("it lets you break into the EVM and do fun things");
        assertTrue(address(vm) != address(0));
    }

    // forge test --match-test test_expectRevert
    function test_expectRevert() public {
        console2.log("vm.expectRevert lets you perform a call, expecting it to revert, and continue execution");

        vm.expectRevert();
        // would normally fail, but it doesn't
        test.revertsIfZero(0);

        console2.log("Despite the failed call, execution continues");
    }

    // forge test --match-test test_prank
    function test_prank() public {
        console2.log("Forge lets you change the msg.sender & tx.origin for a call via the vm.prank cheat");
        vm.prank(bob);
        test.onlyBob();
        // overload the call to set the origin as well
        vm.prank(bob, bob);
        test.onlyBobEOA();

        console2.log("You can persist the change via vm.startPrank");
        vm.startPrank(bob);
        test.onlyBob();
        test.onlyBob();
        console2.log("and end the prank via vm.stopPrank");
        vm.stopPrank();
    }

    // forge test --match-test test_deal
    function test_deal() public {
        console2.log("You can set an address's balance via the vm.deal cheatcode");
        vm.deal(bob, 1);
        assertEq(bob.balance, 1);
    }
}