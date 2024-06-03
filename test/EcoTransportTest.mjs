import * as chai from 'chai';
import chaiAsPromised from 'chai-as-promised';
import { solidity } from 'ethereum-waffle';
import hardhat from 'hardhat';

const { ethers } = hardhat;

chai.use(chaiAsPromised);
chai.use(solidity);
const { expect } = chai;

describe("EcoFriendlyTransportation", function () {
    let EcoFriendlyTransportation, ecoFriendlyTransportContract, contractOwner, user1, user2, otherUsers;

    beforeEach(async function () {
        // Deploy the contract before each test
        EcoFriendlyTransportation = await ethers.getContractFactory("EcoFriendlyTransportation");
        [contractOwner, user1, user2, ...otherUsers] = await ethers.getSigners();
        ecoFriendlyTransportContract = await EcoFriendlyTransportation.deploy();
        await ecoFriendlyTransportContract.deployed();
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            // Check if the owner is set correctly
            expect(await ecoFriendlyTransportContract.contractOwner()).to.equal(contractOwner.address);
        });

        it("Should start in unpaused state", async function () {
            // Check if the contract starts in unpaused state
            expect(await ecoFriendlyTransportContract.isPaused()).to.be.false;
        });
    });

    describe("Vehicle Registration", function () {
        it("Should register a vehicle correctly", async function () {
            // Register a vehicle and check if the details are stored correctly
            await ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric");
            const vehicle = await ecoFriendlyTransportContract.registeredVehicles(user1.address);
            expect(vehicle.make).to.equal("Tesla");
            expect(vehicle.model).to.equal("Model S");
            expect(vehicle.emissionLevel).to.equal("electric");
            expect((vehicle.rewardTier).eq(ethers.BigNumber.from(8)));
        });

        it("Should emit VehicleRegistered event on vehicle registration", async function () {
            // Check if the VehicleRegistered event is emitted with correct details
            await expect(ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric"))
                .to.emit(ecoFriendlyTransportContract, "VehicleRegistered")
                .withArgs(user1.address, 1, "Tesla", "Model S", "electric");
        });
    });

    describe("Mileage Reporting", function () {
        it("Should report mileage and earn reward points", async function () {
            // Register a vehicle, report mileage, and check if reward points are calculated correctly
            await ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric");
            await ecoFriendlyTransportContract.connect(user1).reportMileage(100);
            const points = await ecoFriendlyTransportContract.userRewardPoints(user1.address);
            expect(points).to.equal(ethers.BigNumber.from(800)); // 100 miles * rewardTier 8
        });

        it("Should emit MileageReported event on mileage reporting", async function () {
            // Check if the MileageReported event is emitted with correct details
            await ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric");
            await expect(ecoFriendlyTransportContract.connect(user1).reportMileage(100))
                .to.emit(ecoFriendlyTransportContract, "MileageReported")
                .withArgs(user1.address, 100, ethers.BigNumber.from(800), "Tesla", "Model S");
        });
    });

    describe("Business Registration and Points Redemption", function () {
        it("Should register a business correctly", async function () {
            // Register a business and check if the details are stored correctly
            await ecoFriendlyTransportContract.connect(contractOwner).registerBusiness("Green Store", user2.address);
            const business = await ecoFriendlyTransportContract.registeredBusinesses(user2.address);
            expect(business.name).to.equal("Green Store");
            expect(business.isRegistered).to.be.true;
        });

        it("Should redeem points correctly", async function () {
            // Register a vehicle, report mileage, register a business, and redeem points, then check the balance
            await ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric");
            await ecoFriendlyTransportContract.connect(user1).reportMileage(200); // 1600 points
            await ecoFriendlyTransportContract.connect(contractOwner).registerBusiness("Green Store", user2.address);
            await ecoFriendlyTransportContract.connect(user1).redeemPoints(user2.address, 1000);
            const points = await ecoFriendlyTransportContract.userRewardPoints(user1.address);
            expect(points).to.equal(ethers.BigNumber.from(600)); // 1600 - 1000
        });

        it("Should emit PointsRedeemed event on points redemption", async function () {
            // Check if the PointsRedeemed event is emitted with correct details
            await ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric");
            await ecoFriendlyTransportContract.connect(user1).reportMileage(200);
            await ecoFriendlyTransportContract.connect(contractOwner).registerBusiness("Green Store", user2.address);
            await expect(ecoFriendlyTransportContract.connect(user1).redeemPoints(user2.address, 1000))
                .to.emit(ecoFriendlyTransportContract, "PointsRedeemed")
                .withArgs(user1.address, user2.address, ethers.BigNumber.from(1000));
        });
    });

    describe("Pause and Unpause", function () {
        it("Should pause and unpause the contract", async function () {
            // Pause and unpause the contract, and check the state
            await ecoFriendlyTransportContract.connect(contractOwner).pauseRewardSystem();
            expect(await ecoFriendlyTransportContract.isPaused()).to.be.true;
            await ecoFriendlyTransportContract.connect(contractOwner).unpauseRewardSystem();
            expect(await ecoFriendlyTransportContract.isPaused()).to.be.false;
        });

        it("Should emit RewardPaused and RewardUnpaused events", async function () {
            // Check if the RewardPaused and RewardUnpaused events are emitted correctly
            await expect(ecoFriendlyTransportContract.connect(contractOwner).pauseRewardSystem())
                .to.emit(ecoFriendlyTransportContract, "RewardPaused");
            await expect(ecoFriendlyTransportContract.connect(contractOwner).unpauseRewardSystem())
                .to.emit(ecoFriendlyTransportContract, "RewardUnpaused");
        });

        it("Should not allow registerVehicle when paused", async function () {
            // Pause the contract and try to register a vehicle, expect it to be reverted
            await ecoFriendlyTransportContract.connect(contractOwner).pauseRewardSystem();
            await expect(ecoFriendlyTransportContract.connect(user1).registerVehicle(1, "Tesla", "Model S", "electric"))
                .to.be.revertedWith("Reward system is paused");
        });
    });

    describe("Contract Destruction", function () {
        it("Should allow the owner to destroy the contract", async function () {
            // Check if the owner can destroy the contract
            await expect(ecoFriendlyTransportContract.connect(contractOwner).destroyContract())
                .to.emit(ecoFriendlyTransportContract, "ContractDestroyed");
        });

        it("Should revert when non-owner tries to destroy the contract", async function () {
            // Try to destroy the contract as a non-owner, expect it to be reverted
            await expect(ecoFriendlyTransportContract.connect(user1).destroyContract())
                .to.be.revertedWith("Only owner can call this function");
        });
    });
});
