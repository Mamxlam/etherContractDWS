// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// /**
//  * @title EcoFriendlyTransportation
//  * @dev This contract allows for the registration of eco-friendly vehicles, reporting mileage, and redeeming reward points with registered businesses. The owner can pause the reward system and destroy the contract.
//  */
// contract EcoFriendlyTransportation {
//     address public owner;
//     bool public paused;

//     struct Vehicle {
//         uint ownerId;
//         string make;
//         string model;
//         string emissionLevel;
//         uint rewardTier;
//     }

//     struct Business {
//         string name;
//         bool isRegistered;
//     }

//     mapping(address => Vehicle) public vehicles;
//     mapping(address => uint) public rewardPoints;
//     mapping(address => Business) public businesses;
//     address[] private users;

//     event VehicleRegistered(address indexed user, uint ownerId, string make, string model, string emissionLevel);
//     event MileageReported(address indexed user, uint mileage, uint pointsEarned);
//     event PointsRedeemed(address indexed user, address indexed business, uint points);
//     event RewardPaused();
//     event RewardUnpaused();
//     event ContractDestroyed();
//     event BusinessRegistered(address indexed businessAddress, string name);

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only owner can call this function");
//         _;
//     }

//     modifier whenNotPaused() {
//         require(!paused, "Reward system is paused");
//         _;
//     }

//     /**
//      * @dev Constructor sets the deployer as the owner of the contract and initializes the paused state to false.
//      */
//     constructor() {
//         owner = msg.sender;
//         paused = false;
//     }

//     /**
//      * @notice Registers a vehicle with the provided details.
//      * @dev Adds the vehicle to the mapping and assigns a reward tier based on the emission level.
//      * @param _ownerId The owner's ID of the vehicle.
//      * @param _make The make of the vehicle.
//      * @param _model The model of the vehicle.
//      * @param _emissionLevel The emission level of the vehicle.
//      */
//     function registerVehicle(uint _ownerId, string memory _make, string memory _model, string memory _emissionLevel) public whenNotPaused {
//         require(bytes(_make).length > 0, "Make is required");
//         require(bytes(_model).length > 0, "Model is required");
//         require(bytes(_emissionLevel).length > 0, "Emission level is required");

//         uint rewardTier = _determineRewardTier(_emissionLevel);
//         vehicles[msg.sender] = Vehicle(_ownerId, _make, _model, _emissionLevel, rewardTier);
//         users.push(msg.sender);

//         emit VehicleRegistered(msg.sender, _ownerId, _make, _model, _emissionLevel);
//     }

//     /**
//      * @dev Determines the reward tier based on the emission level of the vehicle.
//      * @param _emissionLevel The emission level of the vehicle.
//      * @return uint The reward tier associated with the emission level.
//      */
//     function _determineRewardTier(string memory _emissionLevel) internal pure returns (uint) {
//         bytes32 emissionHash = keccak256(abi.encodePacked(_emissionLevel));
//         if (emissionHash == keccak256(abi.encodePacked("electric"))) {
//             return 8;
//         } else if (emissionHash == keccak256(abi.encodePacked("hybrid"))) {
//             return 4;
//         } else if (emissionHash == keccak256(abi.encodePacked("low-emission"))) {
//             return 1;
//         } else {
//             revert("Invalid emission level");
//         }
//     }

//     /**
//      * @notice Reports the mileage of a registered vehicle to earn reward points.
//      * @dev Calculates and adds reward points based on the vehicle's reward tier and the mileage reported.
//      * @param _mileage The mileage reported by the vehicle owner.
//      */
//     function reportMileage(uint _mileage) public whenNotPaused {
//         Vehicle memory vehicle = vehicles[msg.sender];
//         require(vehicle.rewardTier > 0, "Vehicle not registered");

//         uint pointsEarned = _mileage * vehicle.rewardTier;
//         rewardPoints[msg.sender] += pointsEarned;

//         emit MileageReported(msg.sender, _mileage, pointsEarned);
//     }

//     /**
//      * @notice Registers a business that accepts reward points.
//      * @dev Only the contract owner can register a business.
//      * @param _name The name of the business.
//      * @param _businessAddress The address of the business which will be the unique identifier.
//      */
//     function registerBusiness(string memory _name, address _businessAddress) public onlyOwner {
//         require(bytes(_name).length > 0, "Business name is required");
//         require(!businesses[_businessAddress].isRegistered, "Business already registered");

//         businesses[_businessAddress] = Business(_name, true);
//         emit BusinessRegistered(_businessAddress, _name);
//     }

//     /**
//      * @notice Redeems reward points with a registered business.
//      * @dev Users can redeem their reward points for benefits provided by the business.
//      * @param _business The address of the registered business.
//      * @param _points The amount of points to redeem.
//      */
//     function redeemPoints(address _business, uint _points) public whenNotPaused {
//     require(rewardPoints[msg.sender] >= 1000, "You need at least 1000 points to redeem.");
//     require(rewardPoints[msg.sender] >= _points, "Insufficient points");
//     require(businesses[_business].isRegistered, "Business not registered");

//     rewardPoints[msg.sender] -= _points;
//     emit PointsRedeemed(msg.sender, _business, _points);
//     }


//     /**
//      * @notice Gets the leaderboard of users based on their reward points.
//      * @dev Sorts the users by their reward points in descending order and returns the top users.
//      * @return topUsers The addresses of the top users.
//      */
//     function getLeaderboard() public view returns (address[] memory topUsers) {
//         uint length = users.length;
//         topUsers = new address[](length);
//         uint[] memory points = new uint[](length);

//         for (uint i = 0; i < length; i++) {
//             points[i] = rewardPoints[users[i]];
//             topUsers[i] = users[i];
//         }

//         _sortLeaderboard(points, topUsers);

//         if (length > 10) {
//             address[] memory top10Users = new address[](10);
//             for (uint i = 0; i < 10; i++) {
//                 top10Users[i] = topUsers[i];
//             }
//             topUsers = top10Users;
//         }
//     }

//     /**
//      * @dev Sorts the leaderboard arrays in descending order of points.
//      * @param points The array of points to sort.
//      * @param topUsers The array of user addresses corresponding to the points.
//      */
//     function _sortLeaderboard(uint[] memory points, address[] memory topUsers) internal pure {
//         uint length = points.length;
//         for (uint i = 0; i < length; i++) {
//             for (uint j = i + 1; j < length; j++) {
//                 if (points[i] < points[j]) {
//                     (points[i], points[j]) = (points[j], points[i]);
//                     (topUsers[i], topUsers[j]) = (topUsers[j], topUsers[i]);
//                 }
//             }
//         }
//     }

//     /**
//      * @notice Pauses the reward system.
//      * @dev Only the contract owner can pause the reward system.
//      */
//     function pauseRewardSystem() public onlyOwner {
//         paused = true;
//         emit RewardPaused();
//     }

//     /**
//      * @notice Unpauses the reward system.
//      * @dev Only the contract owner can unpause the reward system.
//      */
//     function unpauseRewardSystem() public onlyOwner {
//         paused = false;
//         emit RewardUnpaused();
//     }

//     /**
//      * @notice Destroys the contract and transfers remaining funds to the owner.
//      * @dev Only the contract owner can destroy the contract.
//      */
//     function destroyContract() public onlyOwner {
//         emit ContractDestroyed();
//         // Self-destruct is deprecated in latest version of solidity
//         selfdestruct(payable(owner));
//     }
// }
