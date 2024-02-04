// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract QrngRequester is RrpRequesterV0 {
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event WithdrawalRequested(address indexed airnode, address indexed sponsorWallet);

    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    uint256 public randomValue;

    mapping(bytes32 => bool) public expectingRequest;

    constructor(address _airnodeRrp) RrpRequesterV0(_airnodeRrp) {}

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        address _sponsorWallet
    ) external {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    function makeRequestUint256() public {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256.selector,
            ""
        );
        expectingRequest[requestId] = true;
    }

    function fulfillUint256(bytes32 requestId, bytes calldata data)
        external
        onlyAirnodeRrp
    {
        require(expectingRequest[requestId], "Request ID not known");
        expectingRequest[requestId] = false;
        randomValue = abi.decode(data, (uint256));
        emit ReceivedUint256(requestId, randomValue);
    }

    function getRandomNumber() external view returns (uint256) {
        return randomValue;
    }

}