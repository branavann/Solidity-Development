// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Crowdsale.sol";
import "./KycContract.sol"; 

// This contract ensures all tokens are pre-minted 
contract MyTokenSale is Crowdsale {

    // Must import KycContract, otherwise, I got DeclarationError
    KycContract kyc;

    constructor(uint256 rate, address payable wallet, IERC20 token, KycContract _kyc) Crowdsale(rate, wallet, token) public {
        kyc = _kyc;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view override {
        // super keyword enables us to access the _preValidatePurchase() contained within Crowdsale.sol
        super._preValidatePurchase(beneficiary, weiAmount);
        // Ensures the purchaser has completed their kyc forms
        require(kyc.kycCompleted(msg.sender), "Please complete the KYC checks, you're currently not approved to purchase these tokens");
    }
}

