pragma solidity ^0.8.17;

import "forge-std/Test.sol";

contract ForgeStdTest is Test {

    // forge test --match-test test_ConsoleLog
    function test_ConsoleLog() public {
        console2.log("This will be logged to the terminal");

        console.log("Hardhat `console.log` is supported too but console2 is preferred");
        console.log("console.log doesn't do their function signatures correctly :(");
    }

    // forge test --match-test test_AssertionTypes
    function test_AssertionTypes() public {
        string memory a = "You can assert on strings";
        console2.log(a);

        assertEq(a, a);

        console2.log("on fixed bytes");
        assertEq(bytes32("on fixed bytes"), bytes32("on fixed bytes"));
        
        console2.log("on numbers");
        assertEq(uint256(1), uint256(1));

        console2.log("on addresses");
        assertEq(
            address(1),
            address(1),
            "You can also pass an informative string that will be logged if failure"
        );

        console2.log("You can assert a statement is true, but this is less preferred");
        assertTrue(!false);
    }

    // forge test --match-test test_MathUtils
    function test_MathUtils() public {
        console2.log("`forge-std` comes with some math utils!");
        console2.log("Just use the library: stdMath");
        console2.log("This can be helpful for asserting results are within any expected margin of error");
        assertEq(stdMath.delta(uint256(0), uint256(1337)), 1337);
    }

}

