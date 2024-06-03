// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EcoFriendlyTransportation
 * @dev This contract allows for the registration of eco-friendly vehicles, reporting mileage, and redeeming reward points with registered businesses. 
 * The owner can pause the reward system and destroy the contract.
 */
contract EcoFriendlyTransportation {
    // State variables
    address public contractOwner; // Address of the contract owner
    bool public isPaused;         // Boolean to indicate if the reward system is paused

    // Struct to represent a vehicle
    struct Vehicle {
        uint ownerId;          // ID of the vehicle owner
        string make;           // Make of the vehicle
        string model;          // Model of the vehicle
        string emissionLevel;  // Emission level of the vehicle (electric, hybrid, low-emission)
        uint rewardTier;       // Reward tier based on the emission level
    }

    // Struct to represent a business
    struct Business {
        string name;          // Name of the business
        bool isRegistered;    // Boolean to indicate if the business is registered
    }

    // Mappings to store vehicles, reward points, and businesses
    mapping(address => Vehicle) public registeredVehicles;      // Mapping from user address to Vehicle struct
    mapping(address => uint) public userRewardPoints;           // Mapping from user address to reward points
    mapping(address => Business) public registeredBusinesses;   // Mapping from business address to Business struct
    address[] private allUsers;                                 // Array to keep track of user addresses for leaderboard

    // Events to emit on specific actions
    event VehicleRegistered(address indexed user, uint ownerId, string make, string model, string emissionLevel);
    event MileageReported(address indexed user, uint mileage, uint pointsEarned, string make, string model);
    event PointsRedeemed(address indexed user, address indexed business, uint points);
    event RewardPaused();
    event RewardUnpaused();
    event ContractDestroyed();
    event BusinessRegistered(address indexed businessAddress, string name);

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can call this function");
        _;
    }

    // Modifier to ensure function is called only when the reward system is not paused
    modifier whenNotPaused() {
        require(!isPaused, "Reward system is paused");
        _;
    }

    /**
     * @dev Constructor to set the deployer as the owner and initialize the paused state to false.
     * The constructor is called once when the contract is deployed.
     */
    constructor() {
        contractOwner = msg.sender;  // Set the deployer as the contract owner
        isPaused = false;            // Initialize the reward system to be unpaused
    }

    /**
     * @notice Registers a vehicle with the provided details.
     * @dev Adds the vehicle to the mapping and assigns a reward tier based on the emission level.
     * @param _ownerId The owner's ID of the vehicle.
     * @param _make The make of the vehicle.
     * @param _model The model of the vehicle.
     * @param _emissionLevel The emission level of the vehicle.
     */
    function registerVehicle(uint _ownerId, string memory _make, string memory _model, string memory _emissionLevel) public whenNotPaused {
        // Validate the inputs
        require(bytes(_make).length > 0, "Make is required");
        require(bytes(_model).length > 0, "Model is required");
        require(bytes(_emissionLevel).length > 0, "Emission level is required");

        // Determine the reward tier based on emission level
        uint rewardTier = _determineRewardTier(_emissionLevel);

        // Register the vehicle in the mapping
        registeredVehicles[msg.sender] = Vehicle(_ownerId, _make, _model, _emissionLevel, rewardTier);

        // Add the user to the array of users for leaderboard purposes
        allUsers.push(msg.sender);

        // Emit the VehicleRegistered event
        emit VehicleRegistered(msg.sender, _ownerId, _make, _model, _emissionLevel);
    }

    /**
     * @dev Internal function to determine the reward tier based on the emission level of the vehicle.
     * @param _emissionLevel The emission level of the vehicle.
     * @return uint The reward tier associated with the emission level.
     */
    function _determineRewardTier(string memory _emissionLevel) internal pure returns (uint) {
        // Hash the emission level string for comparison
        bytes32 emissionHash = keccak256(abi.encodePacked(_emissionLevel));

        // Return the corresponding reward tier based on the emission level
        if (emissionHash == keccak256(abi.encodePacked("electric"))) {
            return 8; // Electric vehicles get the highest reward tier
        } else if (emissionHash == keccak256(abi.encodePacked("hybrid"))) {
            return 4; // Hybrid vehicles get a medium reward tier
        } else if (emissionHash == keccak256(abi.encodePacked("low-emission"))) {
            return 1; // Low-emission vehicles get the lowest reward tier
        } else {
            revert("Invalid emission level"); // Revert if the emission level is invalid
        }
    }

    /**
     * @notice Reports the mileage of a registered vehicle to earn reward points.
     * @dev Calculates and adds reward points based on the vehicle's reward tier and the mileage reported.
     * @param _mileage The mileage reported by the vehicle owner.
     */
    function reportMileage(uint _mileage) public whenNotPaused {
        // Retrieve the vehicle details from the mapping
        Vehicle memory vehicle = registeredVehicles[msg.sender];
        require(vehicle.rewardTier > 0, "Vehicle not registered");

        // Calculate the points earned based on the mileage and reward tier
        uint pointsEarned = _mileage * vehicle.rewardTier;

        // Update the user's reward points
        userRewardPoints[msg.sender] += pointsEarned;

        // Emit the MileageReported event
        emit MileageReported(msg.sender, _mileage, pointsEarned, vehicle.make, vehicle.model);
    }

    /**
     * @notice Registers a business that accepts reward points.
     * @dev Only the contract owner can register a business.
     * @param _businessName The name of the business.
     * @param _businessAddress The address of the business.
     */
    function registerBusiness(string memory _businessName, address _businessAddress) public onlyOwner {
        // Validate the inputs
        require(bytes(_businessName).length > 0, "Business name is required");
        require(!registeredBusinesses[_businessAddress].isRegistered, "Business already registered");

        // Register the business in the mapping
        registeredBusinesses[_businessAddress] = Business(_businessName, true);

        // Emit the BusinessRegistered event
        emit BusinessRegistered(_businessAddress, _businessName);
    }

    /**
     * @notice Redeems reward points with a registered business.
     * @dev Users can redeem their reward points for benefits provided by the business.
     * @param _businessAddress The address of the registered business.
     * @param _points The amount of points to redeem.
     */
    function redeemPoints(address _businessAddress, uint _points) public whenNotPaused {
        // Ensure the user has enough points to redeem (minimum 1000 points)
        require(userRewardPoints[msg.sender] >= 1000, "You need at least 1000 points to redeem.");
        require(userRewardPoints[msg.sender] >= _points, "Insufficient points");
        require(registeredBusinesses[_businessAddress].isRegistered, "Business not registered");

        // Deduct the points from the user's balance
        userRewardPoints[msg.sender] -= _points;

        // Emit the PointsRedeemed event
        emit PointsRedeemed(msg.sender, _businessAddress, _points);
    }

    /**
     * @notice Gets the leaderboard of users based on their reward points.
     * @dev Sorts the users by their reward points in descending order and returns the top users.
     * @return topUsers The addresses of the top users.
     */
    function getLeaderboard() public view returns (address[] memory topUsers) {
        uint length = allUsers.length;
        topUsers = new address[](length);
        uint[] memory points = new uint[](length);

        // Populate the points and topUsers arrays
        for (uint i = 0; i < length; i++) {
            points[i] = userRewardPoints[allUsers[i]];
            topUsers[i] = allUsers[i];
        }

        // Sort the leaderboard based on points
        _sortLeaderboard(points, topUsers);

        // Return top 10 users if there are more than 10
        if (length > 10) {
            address[] memory top10Users = new address[](10);
            for (uint i = 0; i < 10; i++) {
                top10Users[i] = topUsers[i];
            }
            topUsers = top10Users;
        }
    }

    /**
     * @dev Internal function to sort the leaderboard arrays in descending order of points.
     * @param points The array of points to sort.
     * @param topUsers The array of user addresses corresponding to the points.
     */
    function _sortLeaderboard(uint[] memory points, address[] memory topUsers) internal pure {
        uint length = points.length;
        for (uint i = 0; i < length; i++) {
            for (uint j = i + 1; j < length; j++) {
                if (points[i] < points[j]) {
                    // Swap points
                    (points[i], points[j]) = (points[j], points[i]);
                    // Swap corresponding users
                    (topUsers[i], topUsers[j]) = (topUsers[j], topUsers[i]);
                }
            }
        }
    }

    /**
     * @notice Pauses the reward system.
     * @dev Only the contract owner can pause the reward system.
     */
    function pauseRewardSystem() public onlyOwner {
        isPaused = true; // Set the paused state to true
        emit RewardPaused(); // Emit the RewardPaused event
    }

    /**
     * @notice Unpauses the reward system.
     * @dev Only the contract owner can unpause the reward system.
     */
    function unpauseRewardSystem() public onlyOwner {
        isPaused = false; // Set the paused state to false
        emit RewardUnpaused(); // Emit the RewardUnpaused event
    }

    /**
     * @notice Destroys the contract and transfers remaining funds to the owner.
     * @dev Only the contract owner can destroy the contract.
     */
    function destroyContract() public onlyOwner {
        emit ContractDestroyed(); // Emit the ContractDestroyed event
        selfdestruct(payable(contractOwner)); // Destroy the contract and send remaining funds to the owner
    }
}
