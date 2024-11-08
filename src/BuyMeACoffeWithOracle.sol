//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Ownable} from "@thirdweb-dev/contracts/extension/Ownable.sol";
import {ReentrancyGuard} from "@thirdweb-dev/contracts/external-deps/openzeppelin/security/ReentrancyGuard.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract BuyMeACoffeeAdvanced is Ownable, ReentrancyGuard {
    AggregatorV3Interface internal dataFeed;

    // Network Sepolia
    // Aggregator ETH/USD
    // address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    // 289972000000

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

    // --- Modifiers ---

    // --- Constructor ---

    constructor(uint256 _minimumCoffeePrice) {
        _setupOwner(msg.sender);
        MINIMUM_COFFEE_PRICE = _minimumCoffeePrice;
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
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

    function withdraw() public onlyOwner nonReentrant {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }

    function getChainlinkDataFeedLatestPrice() internal view returns (uint256) {
        // 2,942.25000000
        (, int answer, , , ) = dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function calculateThePriceOfACoffeeInWei(
        uint256 _priceInUSD
    ) public view returns (uint256) {
        uint256 currentPrice = getChainlinkDataFeedLatestPrice();
        uint256 usdPriceInWei = _priceInUSD * 1e18;

        return (usdPriceInWei * 1e18) / currentPrice;
    }

    function _canSetOwner() internal view virtual override returns (bool) {
        return msg.sender == owner();
    }

    // --- Fallback and Receive Functions ---

    receive() external payable {
        if (msg.value < MINIMUM_COFFEE_PRICE) {
            revert NotEnoughEther();
        }

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

    fallback() external payable {
        emit FallbackTriggered(msg.sender, msg.value);
    }
}
