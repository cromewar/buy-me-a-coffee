//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract BuyMeACoffeeAdvanced {
    event NewCoffee(
        address buyer,
        uint256 timestamp,
        string message,
        string name
    );

    struct Coffee {
        uint256 timestamp;
        string message;
        string name;
    }

    mapping(address => Coffee) public coffees;

    function buyACoffee(
        string memory _name,
        string memory _message
    ) public payable {
        require(
            msg.value >= 0.001 ether,
            "Please send 0.01 ether to buy a coffee"
        );

        Coffee memory newCoffee = Coffee(block.timestamp, _message, _name);

        coffees[msg.sender] = newCoffee;

        emit NewCoffee(msg.sender, block.timestamp, _message, _name);
    }

    function getCoffeeInfo(
        address _address
    ) public view returns (uint256, string memory, string memory) {
        Coffee memory coffee = coffees[_address];
        return (coffee.timestamp, coffee.message, coffee.name);
    }

    function withdraw() public {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}
