// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "./IERC20.sol";
import "./Uniswap.sol";

contract TestUniswapLiquidity {
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    event Log(string message, uint256 val);

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) external {
        //Putting both tokens inside this smart contract
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        //Approve uniswap to spend these tokens on our behalf
        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        //Calling the ROUTER
        (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ) = IUniswapV2Router(ROUTER).addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                1,
                1,
                address(this),
                block.timestamp
            );
        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
        emit Log("liquidity", liquidity);
    }

    function removeLiquidity(address _tokenA, address _tokenB) external {
        //NOTE: Here UniswapV2Factory is the contract that manages all the tokens and
        //it also manages to mint and burn liquidity tokens.
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        //getting balance of liquidity tokens pair contract holds.
        uint256 liquidity = IERC20(pair).balanceOf(address(this));

        //we are goin to burn all of our liquidity tokens and claim the max amount of
        //tokenA and tokenB and also all of the trading fee
        //So we willapprove ROUTER to spend all of our liquidity tokens
        IERC20(pair).approve(ROUTER, liquidity);

        //removing liquidity
        (uint256 amountA, uint256 amountB) = IUniswapV2Router(ROUTER)
            .removeLiquidity(
                _tokenA,
                _tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );
        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
    }
}
