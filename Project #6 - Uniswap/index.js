const {ChainId, Fetcher, WETH, Route, Trade, Token, TokenAmount, TradeType} = require("@uniswap/sdk");
const prompt = require("prompt-sync")();
const { toChecksumAddress, checkAddressChecksum } = require("ethereum-checksum-address");

// Specifies the Ethereum chain 
const chainId = ChainId.MAINNET; 

// Global variables 
var erc20Token;
var weth;
var pair;
var route;
var midPriceBeforeTrade;

// Prompts user to input information about the ERC20 token they wish to retrieve information on
var name = prompt("Please enter the name of the ERC20 token: ");
var tokenAddress = prompt("Please enter the token address: ");

// Converts address to checksum address
const checkSumAddress = toChecksumAddress(tokenAddress);
const isCheckedSummedAddress = checkAddressChecksum(checkSumAddress);

// Asynchoronous call 
const checkPrice = async (callback) => {

            // Fetcher object is used to retrieve information on the ERC20 token
            // Provides the default provider, therefore, we need to pass in an EtherJS provider
            erc20Token = await Fetcher.fetchTokenData(chainId, checkSumAddress);
            // uniswap sdk provides WETH information by default, just need to specify the chain
            weth = WETH[chainId];
            pair = await Fetcher.fetchPairData(erc20Token, weth);

            // Route specifies the direction of trading. Since we specified WETH as the second parameter, we retrieve WETH -> ERC20 Token conversion or ERC20 / WETH.
            route = new Route([pair], weth);
            midPriceBeforeTrade = route.midPrice.toSignificant(6);
 
            console.log();
            console.log("The checksummed address for", name, "is", checkSumAddress);
            console.log();
            console.log("Theoretical price (midprice) for this trade is: ");
            console.log("-----------------------------------------------")
            // Returns a string with 6 signficant digits
            console.log("1 WETH can be exchanged for", midPriceBeforeTrade, name);
            console.log("1", name, "can be exchanged for",route.midPrice.invert().toSignificant(6), "WETH");

            callback()

}

const executeTrade = async () => {
 
            // Executing the trade
            const trade = new Trade(route, new TokenAmount(weth, "100000000000000000"), TradeType.EXACT_INPUT);
            const executionPrice = trade.executionPrice.toSignificant(6);
            const midPriceAfterTrade = trade.nextMidPrice.toSignificant(6);
            const midPriceDifference = midPriceBeforeTrade - midPriceAfterTrade;
            console.log();
            console.log("The current execution price (", name, "/ WETH) is: ");
            console.log("----------------------------------------------");
            console.log("1 WETH can be exchanged for", executionPrice, name);
            console.log();
            console.log("The theoretical price (midpoint) for the next trade is: ");
            console.log("--------------------------------------------------------");
            console.log("1 WETH can be exchanged for", midPriceAfterTrade, name);
            console.log();
            console.log("Trade Impact Analysis:");
            console.log("----------------------");
            console.log("1 WETH recieves", midPriceDifference, "fewer", name);
            console.log("The represents a",(midPriceDifference/midPriceBeforeTrade)*100, "% difference in", name,"/ WETH pricing");

}

function render() {
    if(isCheckedSummedAddress) {
        try {
            checkPrice(function () {
            executeTrade();
            });
        } catch (error) {
            console.log("Unable to retrieve information on the provided token.");
        }
        
    } else {
        console.log("Could not perform checksum operation on", address,". Please try another token address");
    }
}

render();

