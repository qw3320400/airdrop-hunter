// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ILayerZeroEndpoint.sol";
import "./ILayerZeroReceiver.sol";
import "./ChainsConfig.sol";

contract Hunter is ERC20, Ownable, ReentrancyGuard, ILayerZeroReceiver, ChainsConfig {

    uint256 constant public Supply = 1000000000 * 1000000000000000000;

    constructor(address _srcEndpoint) ERC20("Hunter", "HTR") Ownable() ReentrancyGuard() {
        _mint(address(this), Supply);
        _updateSrcEndpoint(_srcEndpoint);
    }

    function bridgeMessage(uint16 dstChainID) external payable nonReentrant {
        uint256 nativeFee = this.estimateFees(dstChainID);
        require(msg.value >= nativeFee, "insufficient value for layerzero bridge fee");
        bytes memory remoteAndLocalAddresses = abi.encodePacked(this.getChainConfig(dstChainID), address(this));
        ILayerZeroEndpoint(this.getSrcEndpoint()).send{value : msg.value}(
            dstChainID, 
            remoteAndLocalAddresses, 
            abi.encodePacked(msg.sender), 
            payable(this), 
            address(0x0), 
            bytes("")
        );
        _transfer(address(this), msg.sender, 100000000000000000000);
    }

    function estimateFees(uint16 dstChainID) external view returns (uint256) {
        uint256 nativeFee;
        (nativeFee, ) = ILayerZeroEndpoint(this.getSrcEndpoint()).estimateFees(
            dstChainID, 
            this.getChainConfig(dstChainID), 
            abi.encodePacked(msg.sender), 
            false, 
            bytes("")
        );
        // nativeFee = nativeFee / 100 * 150;
        return nativeFee;
    }

    function withdraw() external onlyOwner nonReentrant {
        require(address(this).balance > 0, "no eth in contract");
        payable(Ownable.owner()).transfer(address(this).balance);
    }

    function lzReceive(uint16, bytes memory, uint64, bytes memory _data) external nonReentrant {
        require(msg.sender == address(this.getSrcEndpoint()));
        address fromAddress;
        assembly {
            fromAddress := mload(add(_data, 20))
        }
        _transfer(address(this), fromAddress, 100000000000000000000);
    }

    function updateSrcEndpoint(address _srcEndpoint) external onlyOwner {
        _updateSrcEndpoint(_srcEndpoint);
    }

    function updateChainConfig(uint16 _chainID, address _userApplication) external onlyOwner {
        _updateChainConfig(_chainID, _userApplication);
    }

    fallback() external payable {
    }

    receive() external payable {
    }
}