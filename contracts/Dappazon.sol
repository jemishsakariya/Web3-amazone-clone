// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract Dappazon {
    address public owner;

    struct Item {
        uint id;
        string name;
        string category;
        string image;
        uint cost;
        uint rating;
        uint stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint => Item) public items;
    mapping(address => uint) public orderCount;
    mapping(address => mapping(uint => Order)) public orders;

    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint cost, uint quantity);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // List Products
    function list(
        uint _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint _cost,
        uint _rating,
        uint _stock
    ) public onlyOwner {
        // Create Item struct
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );
        // Save item struct to blockchain
        items[_id] = item;

        // Emit an event
        emit List(_name, _cost, _stock);
    }

    // Buy Products
    function buy(uint _id) public payable {
        // Receive crypto
        // Fetch item
        Item memory item = items[_id];

        // Require enough ether to buy item
        require(msg.value >= item.cost);

        // Require item is in stock
        require(item.stock > 0);

        // Create an order
        Order memory order = Order(block.timestamp, item);

        // Save order to chain
        orderCount[msg.sender]++; //order ID
        orders[msg.sender][orderCount[msg.sender]] = order;

        // Substrack order
        items[_id].stock = item.stock - 1;

        // Emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    // Withdraw Funds
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
