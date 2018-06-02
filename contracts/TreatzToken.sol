pragma solidity ^0.4.18;

import "./ERC20.sol";
import "./SafeMath.sol";

contract TreatzCoin is ERC20Interface {

    uint public constant _totalSupply = 2000000000;

    string public constant symbol ="TRTZ";
    string public constant name = "Treatz Coin";

    uint initial_price = 1;
    uint256 public constant decimals = 2;
    
    uint discount_ico = 100; // discount for ico. 100 means no discount.

    uint256 internal constant WEI_DECIMALS = 10**decimals;
    uint256 internal constant ETHER_PRICE = 700; //price of Ether USD

    uint256 token_price = initial_price*WEI_DECIMALS/ETHER_PRICE*discount_ico/100; 
    
    // Owner of this contract
    address public owner;

    mapping(address => uint256) balances;
    
    mapping(address => mapping(address => uint256)) allowed;
 
    function TreatzCoin() public {
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }
    
    function totalSupply() public constant returns (uint256 total) {
        total = _totalSupply;
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public returns (bool success) {

        if (balances[msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            
            //if msg.sender is owner, it means charge. 
            //In this case, owner will get approved about the charged balance from receiver.
            if (msg.sender == owner) {
                assert(allowed[_to][owner] + _amount > allowed[_to][msg.sender]);

                allowed[_to][owner] = allowed[_to][owner] + _amount;
            }

            //if _to is owner, it means withdraw. 
            if (_to == owner) {
                if (allowed[msg.sender][owner] > _amount) {
                    allowed[msg.sender][owner] = allowed[msg.sender][owner] - _amount;
                }
                else {
                    allowed[msg.sender][owner] = 0;
                }
            }
            
            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
    address _from,
    address _to,
    uint256 _amount
    ) public returns (bool success) {

        if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    /*
        transform with fee of treatz token.
        This function targets the treatz only wallet for exchange service.
    */
    function transferFromWithFee(
    address _from,
    address _to,
    uint256 _amount,
    uint256 _fee
    ) public returns (bool success) {

        if (balances[_from] >= _amount + _fee
        && allowed[_from][msg.sender] >= _amount + _fee
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= (_amount + _fee);
            allowed[_from][msg.sender] -= (_amount + _fee);
            balances[_to] += _amount;

            //fee is return back to owner
            balances[owner] += _fee;

            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }   
    
    //Withdraw money from contract balance to owner
    function withdraw() public onlyOwner payable returns (bool result) {
        //warning as it may gas-limited, but this is only for sending to owner, not contract.
        return owner.send(this.balance);
    }

    // fallback function can be used to buy tokens
    function () external payable {
        tokens_buy();
    }

    /**
    * Buy tokens 
    */
    function tokens_buy() private returns (bool) { 
    
        uint buy_coins = msg.value/token_price;

        assert(buy_coins <= balances[owner]);
        assert(buy_coins > 0);
        assert(balances[msg.sender] + buy_coins > balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] + buy_coins;        
        return true;
    }
}  