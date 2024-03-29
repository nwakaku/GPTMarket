// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "contracts/QRNGRequester.sol";
import "./IERC4907.sol";

// Main contract definition for the GPTStore.
contract GPTStore is IERC4907, ERC721URIStorage, ReentrancyGuard, QrngRequester {
    

   // Struct to represent information about an Assistant.
    struct Assistant {
        string assistantID;    // Identifier for the assistant.
        uint256 pricePerHour;  // Price per hour in Gwei.
        address owner;         // Owner's address.
    }

    // Struct to represent information about a user's rental.
    struct UserInfo {
        address user;           // Address of the user.
        string URI;             // URI of the rented Assistant.
        uint64 expires;         // Unix timestamp indicating when the rental expires.
        uint256 payment;        // Payment made by the user.
        uint256 assistantNo;    // Identifier of the rented assistant.
        uint256 timeRequested;  // Time requested for the rental.
    }

    // Various state variables.
    uint256 private nftId;             // Counter for NFT IDs.
    uint256 private assistNo = 1;          // Counter for Assistant IDs.
    address private devAddress;            // Address of the developer.
    uint256[] private assistantIds;        // Array to store assistant IDs.

    // Constants defining minimum and maximum rental times.
    uint256 public minRentalTime = 1800;   // 30 minutes
    uint256 public maxRentalTime = 2592000; // 30 days

    // Mapping to store information about rented assistants for each user.
    mapping(uint256 => UserInfo) private _userInfo;
    // Mapping to store information about available assistants.
    mapping(uint256 => Assistant) public assistantsGroups;
    // Mapping to track whether an NFT has been rented by a user.
    mapping(address => uint256[]) private userRentedAssistants;

    // Event emitted when a user rents an assistant.
    event Rent(uint256 nftId, address indexed user);


    constructor(address _airnodeRrp) QrngRequester(_airnodeRrp) ERC721("GPTStore", "GPT") {
        devAddress = msg.sender;
    }

    /// @notice Sets information about available assistants.
    /// @dev This function allows the contract owner to define details for a new assistant.
    /// @param assistantId The identifier for the new assistant.
    /// @param priceHour The price per hour in Gwei for renting the assistant.
    function setAssistants(string memory assistantId, uint256 priceHour) external {
        // Convert price per hour to Gwei.
        uint256 pricePerHourInUSD = priceHour * 1 gwei;

        // Create an Assistant struct and store it in assistantsGroups mapping.
        assistantsGroups[assistNo] = Assistant(assistantId, pricePerHourInUSD, msg.sender);
        assistantIds.push(assistNo);  // Add the assistant ID to the array.
        assistNo++;
    }


    /// @notice Gets details of all available assistants.
    /// @dev This function provides an array of Assistant structs containing information about each available assistant.
    /// @return An array of Assistant structs representing details of all available assistants.
    function getAllAssistantDetails() external view returns (Assistant[] memory) {
        Assistant[] memory allAssistants = new Assistant[](assistantIds.length);

        // Iterate through assistantIds to retrieve information about each assistant.
        for (uint256 i = 0; i < assistantIds.length; i++) {
            allAssistants[i] = assistantsGroups[assistantIds[i]];
        }

        return allAssistants;
    }

    /// @notice Removes an assistant template.
    /// @dev This function allows the contract owner to remove an existing assistant template by ID.
    /// @param id The ID of the assistant template to be removed.
    function removeTemplate(uint256 id) external {
        delete assistantsGroups[id];  // Remove the assistant template from assistantsGroups mapping.

        // Find the index of the id in the assistantIds array.
        uint256 indexToDelete;
        for (uint256 i = 0; i < assistantIds.length; i++) {
            if (assistantIds[i] == id) {
                indexToDelete = i;
                break;
            }
        }
        // If the id was found in the assistantIds array, remove it using .pop()
        if (indexToDelete < assistantIds.length - 1) {
            assistantIds[indexToDelete] = assistantIds[assistantIds.length - 1];
        }
        assistantIds.pop();
        }



    function setMinRentalTime(uint256 time) external  {
        minRentalTime = time;
    }

    function setMaxRentalTime(uint256 time) external  {
        maxRentalTime = time;
    }
    
    
    function setUser(uint256, address, uint64) external pure override {
        revert("cannot change user");
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view virtual returns(address){
        if( uint256(_userInfo[tokenId].expires) >=  block.timestamp){
            return  _userInfo[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return _userInfo[tokenId].expires;
    }

    /// @notice Rents an assistant.
    /// @dev This function allows a user to rent an assistant for a specified duration by providing the assistant number.
    /// @param assistantNo The number of the assistant to be rented.
    function rent(uint256 assistantNo) external payable nonReentrant {
        // Call the makeRequestUint256 function from QrngExample to generate a random number
        makeRequestUint256();

        // Use the random number as the NFT ID for renting
        nftId = randomValue;

        // Various require statements to check conditions for renting.
        require(assistantsGroups[assistantNo].pricePerHour > 0, "Assistant template not found");
        cleanUpOldRentals();

        uint256 timeRequested = msg.value * 3600 / (assistantsGroups[assistantNo].pricePerHour);
        require(timeRequested >= minRentalTime, "Minimum rental time not met");
        require(timeRequested <= maxRentalTime, "Exceeded maximum rental time");

        // Emit event before state changes.
        emit Rent(nftId, msg.sender);

        // Transfer the correct payment to the seller.
        payable(assistantsGroups[assistantNo].owner).transfer(msg.value);

        // Mint the NFT.
        _mint(msg.sender, nftId);
        _setTokenURI(nftId, assistantsGroups[assistantNo].assistantID);

        // Set user information for the rented NFT.
        UserInfo storage info = _userInfo[nftId];
        info.URI = assistantsGroups[assistantNo].assistantID;
        info.user = msg.sender;
        info.expires = uint64(block.timestamp + timeRequested);
        info.assistantNo = assistantNo;
        info.timeRequested = timeRequested;
        info.payment = msg.value; // Store the actual payment
        emit UpdateUser(nftId, info.user, info.expires);

        // Store the rented assistant ID for the user.
        userRentedAssistants[msg.sender].push(nftId);

        // // Increment the NFT ID for the next rental.
        // nftId++;
    }




   /// @notice Extends the rental duration of an NFT.
    /// @dev This function allows the owner of the rented NFT to extend the rental period by providing additional payment.
    /// @param tokenId The ID of the NFT to extend the rental for.
    function extendRental(uint256 tokenId) external payable nonReentrant {
        require(userOf(tokenId) == msg.sender, "Caller is not owner");
        UserInfo storage user = _userInfo[tokenId];
        Assistant memory template = assistantsGroups[user.assistantNo];
        uint256 timeRequested = msg.value * 3600 / template.pricePerHour;
        require(user.expires + timeRequested < block.timestamp + maxRentalTime, "Max rental time exceeded");

        // Emit event before state changes.
        emit Rent(nftId, msg.sender);

        // Transfer the correct payment to the seller.
        payable(template.owner).transfer(msg.value);

        // Update user information for the extended rental.
        user.expires = uint64(user.expires + timeRequested);
        user.payment += msg.value;
    }

    /// @notice Stops the rental of an NFT.
    /// @dev This function allows the owner of the rented NFT to stop the rental before it expires, and receive a refund.
    /// @param tokenId The ID of the NFT to stop the rental for.
    function stopRental(uint256 tokenId) external nonReentrant {
        require(userOf(tokenId) == msg.sender, "Caller is not owner");
        UserInfo storage user = _userInfo[tokenId];
        Assistant memory template = assistantsGroups[user.assistantNo];
        uint256 secondsLeft = (user.expires - block.timestamp) - 60; // Adjusted subtraction
        require(secondsLeft > 0, "Rental has already expired");

        // Emit event before state changes.
        emit Rent(nftId, msg.sender);

        // Calculate the refund to be given to the renter.
        uint256 creditsToGive = secondsLeft * template.pricePerHour / 3600;

        // Check contract balance.
        require(address(this).balance >= creditsToGive, "Insufficient contract balance");

        // Transfer the correct payment to the renter.
        payable(msg.sender).transfer(creditsToGive);

        // Update user information for the stopped rental.
        user.payment -= creditsToGive;

        // Burn the NFT.
        _burn(tokenId);
    }

    /// @notice Gets information about all NFTs rented by the caller.
    /// @dev This function returns an array of UserInfo structs representing details of all rented NFTs by the caller.
    /// @return An array of UserInfo structs representing details of all rented NFTs by the caller.
    function getUserRentedAssistants() external returns (UserInfo[] memory) {
        uint256[] storage rentedIds = userRentedAssistants[msg.sender];
        UserInfo[] memory rentedAssistants = new UserInfo[](rentedIds.length);

        uint256 validNFTsCount = 0;
        for (uint256 i = 0; i < rentedIds.length; i++) {
            uint256 tokenId = rentedIds[i];
            // Check if the user still owns the NFT before retrieving its information.
            if (userOf(tokenId) == msg.sender) {
                rentedAssistants[validNFTsCount] = _userInfo[tokenId];
                validNFTsCount++;
            } else {
                // Remove the invalid NFT from the user's rentedIds array.
                removeInvalidRentedAssistant(i);
            }
        }

        // Resize the array to remove any empty slots.
        assembly {
            mstore(rentedAssistants, validNFTsCount)
        }

        return rentedAssistants;
    }


    /// @notice Removes an invalid rented NFT from the user's rentedIds array.
    /// @dev This internal function is used to remove an invalid rented NFT from the user's rentedIds array.
    /// @param index The index of the invalid rented NFT in the user's rentedIds array.
    function removeInvalidRentedAssistant(uint256 index) public {
        uint256[] storage rentedIds = userRentedAssistants[msg.sender];

        // Move the last element to the position of the removed element.
        if (index < rentedIds.length - 1) {
            rentedIds[index] = rentedIds[rentedIds.length - 1];
        }

        // Remove the last element (pop).
        rentedIds.pop();
    }

    /// @notice Cleans up old rentals.
    /// @dev This function iterates through all NFTs and removes expired rentals, updating state accordingly.
    function cleanUpOldRentals() public {
        uint256[] storage rentedIds = userRentedAssistants[msg.sender];

        for (uint256 i = 0; i < rentedIds.length; i++) {
            uint256 tokenId = rentedIds[i];

            // Check if the user still owns the NFT before retrieving its information.
            if (userOf(tokenId) == msg.sender && userExpires(tokenId) < block.timestamp) {
                // NFT has expired, remove it from userRentedAssistants.
                removeInvalidRentedAssistant(i);

                // Burn the NFT.
                _burn(tokenId);
            }
        }
    }


    function blockerT() public view returns (uint256){
        return block.timestamp;
    }

    /// @notice Removes a rented NFT from the user's rentedIds array.
    /// @dev This internal function is used to remove a rented NFT from the user's rentedIds array.
    /// @param tokenId The ID of the rented NFT to be removed.
    function removeRentedAssistantFromUser(uint256 tokenId) internal {
        address user = userOf(tokenId);
        uint256[] storage rentedIds = userRentedAssistants[user];

        // Find the index of the tokenId in the rentedIds array
        uint256 indexToDelete;
        for (uint256 i = 0; i < rentedIds.length; i++) {
        if (rentedIds[i] == tokenId) {
            indexToDelete = i;
            break;
        }
    }

    // If the tokenId was found in the rentedIds array, remove it using .pop()
    if (indexToDelete < rentedIds.length - 1) {
        rentedIds[indexToDelete] = rentedIds[rentedIds.length - 1];
        }
    rentedIds.pop();
    }


    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }   

}