pragma solidity 0.8.17;
import "forge-std/Test.sol";
contract B {
    uint256 public a = 100;
}

contract Slides is Test {
    function run() public returns (uint256) {
        vm.broadcast();
        B b = new B();
        return b.a();
    }
}