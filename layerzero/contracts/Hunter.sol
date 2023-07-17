// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ILayerZeroEndpoint.sol";
import "./ILayerZeroReceiver.sol";

contract Hunter is ERC20, Ownable, ReentrancyGuard, ILayerZeroReceiver {

    uint256 constant public Supply = 1000000000 * 1000000000000000000;

    // todo check constant below before deploy
    address constant public SrcEndpoint = 0x093D2CF57f764f09C3c2Ac58a42A2601B8C79281; // zksync testnet endpoint
    uint16 constant public DstChainID = 10158; // ploygon zkevm testnet chainid
    address public DstAddress = 0x6aB5Ae6822647046626e83ee6dB8187151E1d5ab; // ploygon zkevm testnet user application

    constructor() ERC20("Hunter", "HTR") Ownable() ReentrancyGuard() {
        _mint(address(this), Supply);
    }

    function bridgeMessage() external payable nonReentrant {
        bytes memory remoteAndLocalAddresses = abi.encodePacked(DstAddress, address(this));
        ILayerZeroEndpoint(SrcEndpoint).send{value : msg.value}(
            DstChainID, 
            remoteAndLocalAddresses, 
            abi.encodePacked(msg.sender), 
            payable(this), 
            address(0x0), 
            bytes("")
        );
        _transfer(address(this), msg.sender, 100000000000000000000);
    }

    function estimateFees() external view returns (uint nativeFee, uint zroFee) {
        return ILayerZeroEndpoint(SrcEndpoint).estimateFees(
            DstChainID, 
            DstAddress, 
            abi.encodePacked(msg.sender), 
            false, 
            bytes("")
        );
    }

    function withdraw() external onlyOwner nonReentrant {
        require(address(this).balance > 0, "no eth in contract");
        payable(Ownable.owner()).transfer(address(this).balance);
    }

    function lzReceive(uint16, bytes memory, uint64, bytes memory _data) external nonReentrant {
        require(msg.sender == address(SrcEndpoint));
        address fromAddress;
        assembly {
            fromAddress := mload(add(_data, 20))
        }
        _transfer(address(this), fromAddress, 100000000000000000000);
    }

    function updateDstAddress(address _dstAddress) external onlyOwner nonReentrant {
        DstAddress = _dstAddress;
    }

    fallback() external payable {
    }

    receive() external payable {
    }
}