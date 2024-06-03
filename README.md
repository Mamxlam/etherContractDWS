# EcoFriendlyTransportation Smart Contract

## Overview

The EcoFriendlyTransportation smart contract allows for the registration of eco-friendly vehicles, reporting mileage, and redeeming reward points with registered businesses. The contract owner has the ability to pause the reward system and destroy the contract if needed.

## Features

- **Vehicle Registration**: Users can register their vehicles with details such as owner ID, make, model, and emission level.
- **Mileage Reporting**: Users can report their vehicle's mileage and earn reward points based on the emission level of their vehicle.
- **Business Registration**: The contract owner can register businesses that accept reward points.
- **Reward Redemption**: Users can redeem their earned reward points for benefits at registered businesses.
- **Leaderboard**: A leaderboard feature to display the top users based on their reward points.
- **Pause and Unpause**: The contract owner can pause and unpause the reward system.
- **Contract Destruction**: The contract owner can destroy the contract and transfer remaining funds to themselves.

## Smart Contract Details

### State Variables

- `contractOwner`: Address of the contract owner.
- `isPaused`: Boolean to indicate if the reward system is paused.

### Structs

- `Vehicle`: Represents a vehicle with `ownerId`, `make`, `model`, `emissionLevel`, and `rewardTier`.
- `Business`: Represents a business with `name` and `isRegistered`.

### Mappings

- `registeredVehicles`: Maps user addresses to their registered vehicles.
- `userRewardPoints`: Maps user addresses to their reward points.
- `registeredBusinesses`: Maps business addresses to their registered business details.

### Events

- `VehicleRegistered`: Emitted when a vehicle is registered.
- `MileageReported`: Emitted when mileage is reported.
- `PointsRedeemed`: Emitted when points are redeemed.
- `RewardPaused`: Emitted when the reward system is paused.
- `RewardUnpaused`: Emitted when the reward system is unpaused.
- `ContractDestroyed`: Emitted when the contract is destroyed.
- `BusinessRegistered`: Emitted when a business is registered.

### Modifiers

- `onlyOwner`: Restricts access to the contract owner.
- `whenNotPaused`: Ensures the function is called only when the reward system is not paused.

## Functions

### Public Functions

- `registerVehicle(uint _ownerId, string memory _make, string memory _model, string memory _emissionLevel)`: Registers a vehicle with the provided details.
- `reportMileage(uint _mileage)`: Reports the mileage of a registered vehicle to earn reward points.
- `registerBusiness(string memory _businessName, address _businessAddress)`: Registers a business that accepts reward points.
- `redeemPoints(address _businessAddress, uint _points)`: Redeems reward points with a registered business.
- `getLeaderboard()`: Gets the leaderboard of users based on their reward points.
- `pauseRewardSystem()`: Pauses the reward system.
- `unpauseRewardSystem()`: Unpauses the reward system.
- `destroyContract()`: Destroys the contract and transfers remaining funds to the owner.

### Internal Functions

- `_determineRewardTier(string memory _emissionLevel)`: Determines the reward tier based on the emission level of the vehicle.
- `_sortLeaderboard(uint[] memory points, address[] memory topUsers)`: Sorts the leaderboard arrays in descending order of points.

## Testing

The smart contract is thoroughly tested using Hardhat and Waffle. The test cases include:

- Contract deployment
- Vehicle registration
- Mileage reporting and reward points calculation
- Business registration
- Points redemption
- Pausing and unpausing the reward system
- Contract destruction

### Running the Tests

1. Install dependencies:

   ```sh
   npm install
   ```

2. Compile the contracts:

   ```sh
   npx hardhat compile
   ```

2. Run the tests:

   ```sh
   npx hardhat test
   ```


## License

This project is licensed under the MIT License - see the LICENSE file for details.