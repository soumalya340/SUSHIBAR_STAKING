// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SushiBar is ERC20 {
    IERC20 public sushi;

    struct Position {
        uint postionId;
        address WalletAddress;
        uint createdDate;
        uint totalAmountLeft;
        uint StakedBalance;
        uint StakedTokens;
        bool open;
    }

    uint public currentPositionId;
    mapping(uint => Position) public positions;
    mapping(address => uint[]) public positionIdsByAddress;

    constructor(IERC20 _sushi) ERC20("SushiBar", "xSUSHI") {
        sushi = _sushi;
    }

    function enter(uint256 _amount) public {
        //uint BalanceOfSender = sushi.balanceOf(msg.sender);
        //require(BalanceOfSender > 0 && BalanceOfSender >= _amount);
        uint _xSUSHI;
        positionIdsByAddress[msg.sender].push(currentPositionId);

        uint256 totalSushi = sushi.balanceOf(address(this));

        uint256 totalShares = totalSupply();

        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
            _xSUSHI = _amount;
        } else {
            uint256 what = (_amount * totalShares) / totalSushi;
            _xSUSHI = what;
            _mint(msg.sender, what);
        }

        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            _xSUSHI,
            _amount,
            _xSUSHI,
            true
        );

        currentPositionId++;

        sushi.transferFrom(msg.sender, address(this), _amount);
    }

    function Timeperiod(uint _positionId) external view returns (uint) {
        uint TimeElapsed = positions[_positionId].createdDate;
        uint _NumDays = CalculateTime(TimeElapsed);
        return _NumDays;
    }

    function CalculateTime(uint _time) private view returns (uint) {
        _time = block.timestamp - _time;
        //_time /= 86400 ;
        return _time / 86400;
    }

    /**Calculate the staking rewards and tax */
    function _calculateReward(uint _xSbalance, uint Time)
        internal
        pure
        returns (uint, uint)
    {
        uint reward;
        uint tax;
        uint rewardAftertax;

        if (Time >= 2 && Time < 4) {
            reward = (_xSbalance * 25) / 100;
            rewardAftertax = (reward * 25) / 100;
            tax = reward - rewardAftertax;
        } 
        else if (Time >= 4 && Time < 6) {
            reward = (_xSbalance * 50) / 100;
            rewardAftertax = reward;
            tax = reward;
        } 
        else if (Time >= 4 && Time < 6) {
            reward = (_xSbalance * 75) / 100;
            rewardAftertax = (reward * 75) / 100;
            tax = reward - rewardAftertax;
        } 
        else {
            rewardAftertax = _xSbalance;
            tax = 0;
        }

        return (rewardAftertax, tax);
    }

    function leave(uint _positionId) public {
        require(
            msg.sender == positions[_positionId].WalletAddress,
            "Not the Owner"
        );
        require(positions[_positionId].open == true, "NOT THE ID IS CLOSED");

        uint TimeElapsed = positions[_positionId].createdDate;

        uint NumDays = CalculateTime(TimeElapsed);

        require(NumDays >= 2, "You can't take out the SUSHI");

        uint NumOfTokens = positions[_positionId].totalAmountLeft;

        (uint _share, uint _tax) = _calculateReward(NumOfTokens, NumDays);

        positions[_positionId].totalAmountLeft -= NumOfTokens;

        if (positions[_positionId].totalAmountLeft == 0)
            positions[_positionId].open = false;

        uint256 totalShares = totalSupply();

        uint256 what1 = (_share * sushi.balanceOf(address(this))) / totalShares;

        uint256 what2 = (_tax * sushi.balanceOf(address(this))) / totalShares;

        _burn(msg.sender, _share + _tax);

        sushi.transfer(msg.sender, what1);

        sushi.transfer(address(this), what2);
    }
}
