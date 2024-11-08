//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract BuyMeACoffee {
    // Event each time someone buys me a coffee
    // In Solidity, an event is a way for your smart contract to communicate that something of interest has happened. When an event is emitted, it stores the arguments passed in the transaction logs, which are a special data structure in the Ethereum blockchain. These logs can be accessed by external applications, such as a web interface or other smart contracts, to react to the event.
    // In simple terms, think of an event as a way for your smart contract to "announce" that something has happened, and this announcement can be "heard" by anyone who is listening for it.
    // Here's a breakdown of the NewCoffee event in your code:
    // address buyer: The address of the person who bought the coffee.
    // uint256 timestamp: The time when the coffee was bought.
    // string message: A message from the buyer.
    // string name: The name of the buyer.
    // When someone buys a coffee, this event will be emitted, and the details of the purchase will be recorded in the blockchain logs.

    event NewCoffee(
        address buyer,
        uint256 timestamp,
        string message,
        string name,
        uint256 value
    );

    // Struct to store the information about each coffee
    // In Solidity, a struct is a custom data type that allows you to group together related variables. It is similar to a record or a class in other programming languages. For example, the Coffee struct groups together information about a coffee purchase, including the buyer's address, the timestamp of the purchase, a message, and the buyer's name.
    struct Coffee {
        uint256 timestamp;
        string message;
        string name;
        uint256 value;
    }

    // mapping to store sender address and the coffee information
    // In Solidity, a mapping is like a dictionary or a hash table in other programming languages. It allows you to store key-value pairs, where each key is unique and maps to a specific value. In your code, the coffees mapping stores an address (the key) and associates it with a Coffee struct (the value). This means you can look up the coffee information for any given address.
    mapping(address => Coffee) public coffees;

    // In Solidity, a function is a reusable block of code that performs a specific task. Functions can take inputs, execute code, and return outputs. They help organize and modularize code, making it easier to read, maintain, and reuse.

    // Here's the key parts of a function in Solidity:

    // Function Declaration: This includes the function name and any parameters it takes.
    // Visibility: Specifies who can call the function (e.g., public, private).
    // Payable: Indicates that the function can receive Ether.
    // Return Type: Specifies what the function returns, if anything.
    // Function Body: Contains the code that runs when the function is called.

    // In our example, the buyACoffee function allows users to buy a coffee by sending at least 0.001 Ether, records the purchase, and emits an event to announce it.

    function buyACoffee(
        string memory _name,
        string memory _message
    ) public payable {
        require(
            msg.value >= 0.001 ether,
            "Please send 0.01 ether to buy a coffee"
        );

        // Create a new Coffee struct with the buyer's information
        Coffee memory newCoffee = Coffee(
            block.timestamp,
            _message,
            _name,
            msg.value
        );

        // Assign the newCoffee struct to the sender's address in the coffees mapping
        coffees[msg.sender] = newCoffee;

        // Emit the NewCoffee event to announce the purchase
        emit NewCoffee(msg.sender, block.timestamp, _message, _name, msg.value);
    }

    // View function to get the coffee information for a specific address
    // In Solidity, a view function is a special type of function that does not modify the state of the contract. It is read-only and does not consume gas when called externally. This means that view functions can be called for free and do not require a transaction to be included in a block.

    function getCoffeeInfo(
        address _address
    ) public view returns (uint256, string memory, string memory) {
        Coffee memory coffee = coffees[_address];
        return (coffee.timestamp, coffee.message, coffee.name);
    }

    // withdraw function to withdraw the balance from the contract

    function withdraw() public {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}
