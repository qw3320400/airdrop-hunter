// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChainsConfig {
    struct ChainConfig {
        uint16 ChainID;
        address UserApplication;
    }

    address private srcEndpoint;

    mapping(uint16 => ChainConfig) private chainsConfig;

    function getSrcEndpoint() external view returns (address) {
        return srcEndpoint;
    }

    function getChainConfig(uint16 chainID) external view returns (address) {
        return  chainsConfig[chainID].UserApplication;
    }

    function _updateSrcEndpoint(address _srcEndpoint) internal {
        srcEndpoint = _srcEndpoint;
    }

    function _updateChainConfig(uint16 _chainID, address _userApplication) internal {
        chainsConfig[_chainID].ChainID = _chainID;
        chainsConfig[_chainID].UserApplication = _userApplication;
    }
}