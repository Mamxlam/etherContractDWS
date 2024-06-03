// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract EcoFriendlyTransportation_V1 {

//     // The address of the contract owner
//     address public owner;
//     // Boolean to check if the contract is paused
//     bool public paused;

//     // Struct to store vehicle details
//     struct Vehicle {
//         uint ownerId;
//         string make;
//         string model;
//         string emissionLevel;
//         uint rewardTier;
//     }

//     // Struct to store business details
//     struct Business {
//         string name;
//         bool isRegistered;
//     }

//     // Mapping to store vehicles registered by addresses
//     mapping(address => Vehicle) public vehicles;
//     // Mapping to store reward points of users by addresses
//     mapping(address => uint) public rewardPoints;
//     // Mapping to store registered businesses by addresses
//     mapping(address => Business) public businesses;

//     // Array to store user addresses
//     address[] public users;
//     // Array to store business addresses
//     address[] public businessList;

//     // Events to be emitted for different actions
//     event VehicleRegistered(address indexed user, uint ownerId, string make, string model, string emissionLevel);
//     event MileageReported(address indexed user, uint mileage, uint pointsEarned);
//     event PointsRedeemed(address indexed user, address indexed business, uint points);
//     event RewardPaused();
//     event RewardUnpaused();
//     event ContractDestroyed();

//     // Modifier to restrict access to only the contract owner
//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only owner can call this function");
//         _;
//     }

//     // Modifier to allow function calls only when the contract is not paused
//     modifier whenNotPaused() {
//         require(!paused, "Reward system is paused");
//         _;
//     }

//     // Constructor to initialize the contract owner and set paused to false
//     constructor() {
//         owner = msg.sender;
//         paused = false;
//     }

//     // Function to register a vehicle with given details
//     function registerVehicle(uint _ownerId, string memory _make, string memory _model, string memory _emissionLevel) public whenNotPaused {
//         // Ensure required fields are provided
//         require(bytes(_make).length > 0, "Make is required");
//         require(bytes(_model).length > 0, "Model is required");
//         require(bytes(_emissionLevel).length > 0, "Emission level is required");

//         // Determine the reward tier based on emission level
//         uint rewardTier;
//         if (keccak256(abi.encodePacked(_emissionLevel)) == keccak256(abi.encodePacked("electric"))) {
//             rewardTier = 8; // Highest reward for electric vehicles
//         } else if (keccak256(abi.encodePacked(_emissionLevel)) == keccak256(abi.encodePacked("hybrid"))) {
//             rewardTier = 4; // Moderate reward for hybrid vehicles
//         } else if (keccak256(abi.encodePacked(_emissionLevel)) == keccak256(abi.encodePacked("low-emission"))) {
//             rewardTier = 1; // Lowest reward for low-emission vehicles
//         } else {
//             revert("Invalid emission level");
//         }

//         // Store the vehicle details in the mapping
//         vehicles[msg.sender] = Vehicle(_ownerId, _make, _model, _emissionLevel, rewardTier);
//         // Add the user to the users array
//         users.push(msg.sender);

//         // Emit the VehicleRegistered event
//         emit VehicleRegistered(msg.sender, _ownerId, _make, _model, _emissionLevel);
//     }

//     // Function to report mileage and earn reward points
//     function reportMileage(uint _mileage) public whenNotPaused {
//         // Ensure the vehicle is registered
//         require(vehicles[msg.sender].rewardTier > 0, "Vehicle not registered");

//         // Calculate points earned based on mileage and reward tier
//         uint pointsEarned = _mileage * vehicles[msg.sender].rewardTier;
//         // Update the user's reward points
//         rewardPoints[msg.sender] += pointsEarned;

//         // Emit the MileageReported event
//         emit MileageReported(msg.sender, _mileage, pointsEarned);
//     }

//     // Function to register a business with given details
//     function registerBusiness(string memory _name, address _businessAddress) public onlyOwner {
//         // Ensure the business name is provided
//         require(bytes(_name).length > 0, "Business name is required");
//         // Ensure the business is not already registered
//         require(!businesses[_businessAddress].isRegistered, "Business already registered");

//         // Store the business details in the mapping
//         businesses[_businessAddress] = Business(_name, true);
//         // Add the business to the businessList array
//         businessList.push(_businessAddress);
//     }

//     // Function to redeem reward points for discounts at businesses
//     function redeemPoints(address _business, uint _points) public {
//         // Ensure the user has enough points to redeem
//         require(rewardPoints[msg.sender] >= 1000, "Not enough points to redeem");
//         // Ensure the business is registered
//         require(businesses[_business].isRegistered, "Business not registered");
//         // Ensure the user has sufficient points
//         require(rewardPoints[msg.sender] >= _points, "Insufficient points");

//         // Deduct the points from the user's account
//         rewardPoints[msg.sender] -= _points;

//         // Emit the PointsRedeemed event
//         emit PointsRedeemed(msg.sender, _business, _points);
//     }

//     // Function to get the leaderboard of top 10 users with the most reward points
//     function getLeaderboard() public view returns (address[] memory topUsers) {
//         address[] memory userAddresses = users;
//         uint length = userAddresses.length;
//         uint[] memory points = new uint[](length);
//         topUsers = new address[](length);

//         // Copy the reward points and addresses into arrays
//         for (uint i = 0; i < length; i++) {
//             points[i] = rewardPoints[userAddresses[i]];
//             topUsers[i] = userAddresses[i];
//         }

//         // Sort the arrays based on reward points in descending order
//         for (uint i = 0; i < length; i++) {
//             for (uint j = i + 1; j < length; j++) {
//                 if (points[i] < points[j]) {
//                     (points[i], points[j]) = (points[j], points[i]);
//                     (topUsers[i], topUsers[j]) = (topUsers[j], topUsers[i]);
//                 }
//             }
//         }

//         // Return only the top 10 users if there are more than 10
//         if (length > 10) {
//             address[] memory top10Users = new address[](10);
//             for (uint i = 0; i < 10; i++) {
//                 top10Users[i] = topUsers[i];
//             }
//             topUsers = top10Users;
//         }
//     }

//     // Function to pause the reward system
//     function pauseRewardSystem() public onlyOwner {
//         paused = true;
//         emit RewardPaused();
//     }

//     // Function to unpause the reward system
//     function unpauseRewardSystem() public onlyOwner {
//         paused = false;
//         emit RewardUnpaused();
//     }

//     // Function to destroy the contract and transfer remaining ether to the owner
//     function destroyContract() public onlyOwner {
//         emit ContractDestroyed();
//         selfdestruct(payable(owner));
//     }
// }




// // Design Choices:
// // Owner Control:

// // The owner variable is used to designate the deployer of the contract as the contract owner.
// // The onlyOwner modifier restricts certain functions to be called only by the owner, ensuring administrative control over critical operations like pausing, unpausing, and destroying the contract.
// // Pause Mechanism:

// // The paused variable and whenNotPaused modifier are used to temporarily halt certain functions of the contract. This is useful for maintenance or emergency situations.
// // Functions like registerVehicle and reportMileage are guarded by this modifier to prevent their execution when the system is paused.
// // Vehicle Registration and Reward System:

// // Vehicles are registered with details including ownerId, make, model, emissionLevel, and rewardTier.
// // The reward tier is determined based on the emission level, with higher rewards for more eco-friendly vehicles (electric, hybrid, low-emission).
// // The design promotes the use of eco-friendly vehicles by assigning higher reward points to vehicles with lower emissions.
// // Business Registration and Points Redemption:

// // Businesses can be registered by the owner to participate in the reward system.
// // Users can redeem their reward points for discounts at registered businesses, promoting local commerce and incentivizing eco-friendly behavior.
// // Leaderboard:

// // The getLeaderboard function sorts and returns the top 10 users with the most reward points.
// // This feature encourages competition among users to earn more points and promotes consistent use of eco-friendly transportation.
// // Contract Destruction:

// // The destroyContract function allows the owner to permanently disable the contract and transfer any remaining funds to the owner's address.
// // This function is guarded by the onlyOwner modifier to prevent unauthorized destruction of the contract.
// // By incorporating these design choices, the contract aims to create a robust system for promoting eco-friendly transportation through user rewards and business partnerships while ensuring control and safety through administrative functions and a pause mechanism.




// // String Comparison using keccak256
// // In Solidity, direct comparison of strings using == is not straightforward due to how strings are handled in the EVM (Ethereum Virtual Machine). Instead, we use the keccak256 hash function to compare the hashed values of the strings. Hashing the strings and then comparing the hashes is both efficient and secure.



// // Detailed Steps
// // Encode the Strings:

// // abi.encodePacked is used to pack the string into bytes. This is necessary because keccak256 operates on bytes, not directly on strings.
// // Example: abi.encodePacked(_emissionLevel) converts the input string _emissionLevel into a bytes array.
// // Generate the Hash:

// // keccak256 takes the bytes array and produces a 32-byte hash.
// // Example: keccak256(abi.encodePacked(_emissionLevel)) generates a hash for the string stored in _emissionLevel.
// // Compare the Hashes:

// // The == operator is used to compare the hashes of the input string and the reference string ("electric", "hybrid", "low-emission").
// // If the hashes match, it means the strings are identical.
// // Why Use keccak256?
// // Efficiency: Comparing hashes (fixed-size bytes) is more efficient than comparing variable-length strings.
// // Security: keccak256 provides a secure way to handle and compare strings, minimizing the risk of collisions and ensuring that the comparison is tamper-proof.
// // Consistency: keccak256 ensures a consistent hash value for the same input, making it reliable for string comparisons.