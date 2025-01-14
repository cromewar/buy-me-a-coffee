//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract BuyMeACoffeeAdvanced {
    // --- Events ---
    event NewCoffee(
        address buyer,
        uint256 timestamp,
        string message,
        string name,
        uint256 value
    );

    // --- Errors ---
    error NotEnoughEther();

    event FallbackTriggered(address indexed sender, uint256 value);

    // --- Variables ---

    address public owner;
    uint256 public immutable MINIMUM_COFFEE_PRICE;
    bool private locked = false;

    struct Coffee {
        uint256 timestamp;
        string message;
        string name;
        uint256 value;
    }

    // --- Mappings ---

    mapping(address => Coffee) public coffees;

    // Modifier for access control
    // In solidity, a modifier is a reusable piece of code that can be attached to a function to modify its behavior. Modifiers are used to enforce access control, validate inputs, and perform other checks before executing the function's code.

    // --- Modifiers ---

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    // constructor of the contract
    // In solidity, a constructor is a special function that is executed only once when the contract is deployed. It is used to initialize the contract's state and perform any setup tasks.
    // In this example, the constructor sets the owner of the contract to the address that deployed it and sets the minimum coffee price to the value passed as an argument.
    constructor(uint256 _minimumCoffeePrice) {
        owner = msg.sender;
        MINIMUM_COFFEE_PRICE = _minimumCoffeePrice;
    }

    function buyACoffee(
        string memory _name,
        string memory _message
    ) public payable {
        require(msg.value >= MINIMUM_COFFEE_PRICE, NotEnoughEther());

        Coffee memory newCoffee = Coffee(
            block.timestamp,
            _message,
            _name,
            msg.value
        );

        coffees[msg.sender] = newCoffee;

        emit NewCoffee(msg.sender, block.timestamp, _message, _name, msg.value);
    }

    // --- Functions ---

    function getCoffeeInfo(
        address _address
    ) public view returns (uint256, string memory, string memory) {
        Coffee memory coffee = coffees[_address];
        return (coffee.timestamp, coffee.message, coffee.name);
    }

    // Adding the ability to withdraw the contract balance just to the owner
    function withdraw() public onlyOwner nonReentrant {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }

    // --- Fallback and Receive Functions ---

    // In Solidity, the receive() and fallback() functions are special functions that are automatically called when a contract receives Ether or when a call does not match any other function signature. These functions can be used to handle unexpected Ether transfers and calls, and can be customized to perform specific actions.

    // This functions is triggered when someone sends Ether without data
    receive() external payable {
        if (msg.value < MINIMUM_COFFEE_PRICE) {
            revert NotEnoughEther();
        }

        // This will automaticall record the sender and the value sent as an Anonymous donator
        Coffee memory newCoffee = Coffee(
            block.timestamp,
            "Anonymous donation",
            "Anonymous",
            msg.value
        );

        coffees[msg.sender] = newCoffee;
        emit NewCoffee(
            msg.sender,
            block.timestamp,
            "Anonymous donation",
            "Anonymous",
            msg.value
        );
    }

    // This function is triggered if a call does not match any function signature

    fallback() external payable {
        emit FallbackTriggered(msg.sender, msg.value);
    }
}
