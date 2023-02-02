# Overview

- ### Getting Started
- ### Basic Tests
- ### Forge-std
- ### Basic Cheatcodes
- ### Traces
- ### Anvil
- ### Fork Tests
- ### Fuzz Testing
- ### Advanced cheatcodes
- ### New Features
- ## Sneak Peak

---
# Getting Started

#### 1. `$ curl -L https://foundry.paradigm.xyz | bash`
#### 2. `$ foundryup`
#### 3. `$ forge init how_to_foundry_2.0`

```bash
/// curl -L https://foundry.paradigm.xyz | bash
```

```bash
/// foundryup
```
---
# Basic Tests

## `setUp` function

### This is automatically ran before each test, and can be used to setup any state necessary for your test.

```solidity
function setUp() public {
	console2.log("setUp is equivalent to `beforeEach`");
	console2.log("We can setup any state we need to");
	
	a = new A();

    testNumber = 42;
}
```

## Test functions

### Each test must start with `test` to be recognized by Foundry.

```solidity
// forge test --match-test test_NumberIs42
function test_NumberIs42() public {
    assertEq(testNumber, 42);
}

// forge test --match-test testFail_PleaseDontUseThis
function testFail_PleaseDontUseThis() public {
    console2.log("`testFail` is an anti-pattern. Use vm.expectRevert instead.");
    assertTrue(false);
}
```
---
# `Forge-Std`

## Utilities
####  `stdAssertions`
A helper for writing assertions
####  `stdMath`
A helper for math related testing
####  `stdStorage`
A helper for reading and affecting the storage of the EVM
####  `stdCheats`
A helper for improving cheatcode UX

---
# Basic Cheatcodes

#### `vm`
The contract for modifying the EVM via cheatcodes
#### `expectRevert`
Prevent a reverting call to end execution
#### `prank`
Send a call as someone else
#### `deal`
Set ethereum balance


---

# Traces
```
  [<Gas Usage>] <Contract>::<Function>(<Parameters>)
    ├─ [<Gas Usage>] <Contract>::<Function>(<Parameters>)
    │   └─ ← <Return Value>
    └─ ← <Return Value>
```

If your terminal supports color, the traces will also come with a variety of colors:

*  Green: For calls that do not revert
*  Red: For reverting calls
*  Blue: For calls to cheat codes
*  Cyan: For emitted logs
*  Yellow: For contract deployments

---
# Anvil

Blazing fast `ganache` alternative, just run `anvil`:
```



                             _   _
                            (_) | |
      __ _   _ __   __   __  _  | |
     / _` | | '_ \  \ \ / / | | | |
    | (_| | | | | |  \ V /  | | | |
     \__,_| |_| |_|   \_/   |_| |_|

    0.1.0 (cd7850b 2023-02-02T00:05:21.267863Z)
    https://github.com/foundry-rs/foundry

Available Accounts
==================

(0) "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" (10000 ETH)
					.
					.
					.
```
---

# Fork Tests
## Allows you to use mainnet state for your tests

#### `forge test --fork-url <your_rpc_url>`

#### Accessible in Solidity
```solidity
contract ForkTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 optimismFork;
    
    //Access variables from .env file via vm.envString("varname")
    //Replace ALCHEMY_KEY by your alchemy key or Etherscan key, change RPC url if need
    //inside your .env file e.g: 
    //MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/ALCHEMY_KEY'
    //string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    //string OPTIMISM_RPC_URL = vm.envString("OPTIMISM_RPC_URL");

    // create two _different_ forks during setup
    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        optimismFork = vm.createFork(OPTIMISM_RPC_URL);
    }

    // demonstrate fork ids are unique
    function testForkIdDiffer() public {
        assert(mainnetFork != optimismFork);
    }

    // manage multiple forks in the same test
    function testCanSwitchForks() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        vm.selectFork(optimismFork);
        assertEq(vm.activeFork(), optimismFork);
    }
}
```

---
# Fuzz Tests

## Property-based testing is a way of testing general behaviors as opposed to isolated scenarios.

```solidity
contract Safe {
    receive() external payable {}

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function testWithdraw() public {
        payable(address(safe)).transfer(1 ether);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + 1 ether, postBalance);
    }
}
```

---
# Fuzz Tests

```solidity
contract Safe {
    receive() external payable {}

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    // .. snip .. //

    // forge test --match-test testFuzz_Withdraw
    function testFuzz_Withdraw(uint256 amount) public {
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
```
---
# Fuzz Tests

```solidity
contract Safe {
    receive() external payable {}

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    // .. snip .. //

    // forge test --match-test testFuzz_Withdraw
    function testFuzz_Withdraw(uint256 amount) public {
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
```

`[FAIL. Reason: EvmError: Revert Counterexample: calldata=0x29facca70000000000000000000000000000000000000001000000000000000000000000, args=[79228162514264337593543950336]] testFuzz_Withdraw(uint256) (runs: 2, μ: 19491, ~: 19491)`

---
# Fuzz Tests

```solidity
contract Safe {
    receive() external payable {}

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    // .. snip .. //

    // forge test --match-test testFuzz_Withdraw
    function testFuzz_Withdraw(uint256 amount) public {
    	// bound the fuzzed amount between 0 and balance
    	amount = bound(amount, 0, address(safe).balance);

        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}
```

# [PASS] testFuzz_Withdraw(uint256) (runs: 256, μ: 10766, ~: 10773)

---
# Advanced Cheatcodes

```solidity
contract B {
	uint256 public a;
}

contract T is Test {
	ERC20 erc20;
	B b;
	function setUp() public {
		erc20 = new ERC20();
		b = new B();
	}

	function test_writeBalance() public {
		// set my token balance to 10e18, and update totalSupply
		deal(address(erc20), address(this), 10e18, true);
	}

	function test_writeArbitrary() public {
		// write to storage
		stdstore
			.target(address(b))
			.sig(b.a.selector)
			.checked_write(100);
		assertEq(b.a(), 100);
	}
}
```
---

# Advanced Cheatcodes

```solidity
contract B {
	uint256 public a;
}

contract T is Test {
	mapping(string => bytes) default_config;
	string config_json;

	uint256 myVar;
	function setUp() public {
		string memory loc = "./config/";
        string memory network = vm.envString("NETWORK");
        string memory path = string.concat(loc, network);
        string memory full_path = string.concat(path, ".json");
        config_json = vm.readFile(full_path);

        myVar = readUintFromDeployConfig("myVar");
	}

	function readDeployConfig(string memory key) internal returns (bytes memory) {
        bytes memory val = vm.parseJson(config_json, key);
        return val;
    }

    function readUintFromDeployConfig(string memory key) internal returns (uint256) {
        bytes memory val = readDeployConfig(key);
        if (val.length > 0) {
            return abi.decode(val, (uint256));
        } else {
            bytes memory default_conf = default_config[key];
            if (default_conf.length > 0) {
                return abi.decode(default_conf, (uint256));
            } else {
                return 0;
            }
        }
    }
}
```
---


## New Features

- ### `forge script`
- ### `forge coverage`
- ### `forge doc`
- ### `chisel`
- ### New Cheatcodes
- ### Multichain deployments
- ### Invariant tests



---

# `forge script`

```solidity
pragma solidity 0.8.17;
import "forge-std/Script.sol";

contract B {
	uint256 public a = 100;
}

contract Slides is Script {
	function run() public returns (uint256) {
		uint256 pvk = vm.envUint("PRIVATE_KEY");
		address deployer = vm.rememberKey(pvk);

		vm.broadcast(deployer);
		B b = new B();
	    return b.a();
	}
}
```

---

# `forge coverage`

`$ forge coverage`:

| File                 | % Lines     | % Statements | % Branches    | % Funcs     |
|----------------------|-------------|--------------|---------------|-------------|
| script/Counter.s.sol | 0.00% (0/1) | 0.00% (0/1)  | 100.00% (0/0) | 0.00% (0/2) |
| src/Bridger.sol      | 0.00% (0/2) | 0.00% (0/2)  | 100.00% (0/0) | 0.00% (0/2) |
| Total                | 0.00% (0/3) | 0.00% (0/3)  | 100.00% (0/0) | 0.00% (0/4) |


---
# `forge doc`

Output:


~~~xargs cat
docs/src/src/Bridger.sol/contract.Counter.md
~~~

---

# `chisel`

### Demo


---

# New Cheatcodes

### `pauseGasMetering` & `resumeGasMetering`
Pause gas metering! You want to DoS yourself? Do it!
\* note: solidity doesn't manage memory and there is a configurable memory limit set in foundry
### `parseJson` & other JSON functions
Parse json that has been loaded either from a file or input as a string
### File manipulation via `writeFile`, `readFile`, etc
Write/read data to/from a file

### `transact`
Fetches the given transaction from the active fork and executes it on the current state


---

# Invariant tests

### Dive into Optimism-Bedrock


---

# Sneak Peak

## Introducing `pyrometer` a new tool from Nascent

### Abstract Interpretation
Similar to symbolic execution. U
### Bound analysis
`uint256(x) is in the range 0 - 2**256-1`
### Storage Write queries
`How can I set this storage variable to a particular range?`
### Taint analysis
### "Slither on steroids"
### Blazing fast (~1ms per contract)


