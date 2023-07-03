#[starknet::contract]
mod StakingToken {
/////////////////////////////
//LIBRARY IMPORTS
/////////////////////////////
use starknet::ContractAddress;
use starknet::{get_caller_address, get_contract_address, get_block_timestamp};
use new_syntax::interfaces::IERC20DispatcherTrait;
 use new_syntax::interfaces::IERC20Dispatcher;
 use integer::Into;

/////////////////////
//STAKING DETAIL
/////////////////////
// #[derive(Drop)]
 #[derive(Drop,storage_access::StorageAccess)]
struct StakeDetail {
    timeStaked: u64,
    amount: u256,
    status:bool,
}

////////////////////
//STORAGE
////////////////////
#[storage]
struct Storage{
    staker: LegacyMap::<ContractAddress, StakeDetail>
}


//////////////////
// CONSTANT
//////////////////
const minStakeTime: u64 = 259200_u64;


/////////////////
//EVENTS
/////////////////

#[event]
#[derive(Drop, starknet::Event)]
enum Event{
    TokenStaked:TokenStaked,
    TokenWithdraw:TokenWithdraw
}

#[derive(Drop, starknet::Event)]
struct TokenStaked{
    staker: ContractAddress,
    amount: u256,
    time: u64
}

#[derive(Drop, starknet::Event)]
struct TokenWithdraw{
    staker: ContractAddress,
    amount: u256,
    time: u64
}

// stakeToken

#[external]
fn stakeToken(ref self:ContractState, amount:u256, token_address:ContractAddress) {
let caller:ContractAddress = get_caller_address();
let address_this = get_contract_address();
assert((IERC20Dispatcher{contract_address:token_address}.balance_of(caller) >= amount), 'ERC20:Insufficient Balance');
IERC20Dispatcher{contract_address:token_address}.transfer_from(caller, address_this, amount);
let stake_status:bool = self.staker.read(caller).status;
let stake_time:u64 = self.staker.read(caller).timeStaked;
let mut stake:StakeDetail = self.staker.read(caller);
if stake_status == true{
    let day_spent = get_block_timestamp() - stake_time;
    if day_spent > minStakeTime{
        let reward = calculateReward(self,caller);
        stake.amount += reward;
        stake.amount -= amount;
        stake.timeStaked += get_block_timestamp();
    }else{
        stake.amount -= amount;
        stake.timeStaked = get_block_timestamp();
    }
    IERC20Dispatcher{contract_address:token_address}.transfer(caller, amount);
    stake.timeStaked = get_block_timestamp();

    if stake.amount > 0{
        stake.status = true;
    }else{
        stake.status = false;
    }
}
self.emit(Event::TokenStaked(TokenStaked{staker:caller, amount, time:stake_time}));
}

// withdrawToken
#[external]
fn withdrawToken(ref self:ContractState,amount:u256, token_address:ContractAddress){
let caller = get_caller_address();
let stake_amount = self.staker.read(caller).amount;
let stake_time = self.staker.read(caller).timeStaked;
let day_spent = get_block_timestamp() - stake_time; 
let mut stake:StakeDetail = self.staker.read(caller);
assert(amount <= stake_amount, 'Insufficient fund');
if day_spent > minStakeTime {
    let reward = calculateReward(self,caller);
    stake.amount += reward;
    stake.amount -= amount;
    stake.timeStaked = get_block_timestamp();
}else{
    stake.amount = stake.amount - amount;
    stake.timeStaked = get_block_timestamp();
}
IERC20Dispatcher{contract_address:token_address}.transfer(caller, amount);
stake.timeStaked = get_block_timestamp();

if stake.amount > 0 {
    stake.status = true;
}else{
    stake.status = false;
}
self.emit(Event::TokenWithdraw(TokenWithdraw{staker:caller, amount, time:stake_time}));
}

// calculateReward
#[internal]

fn calculateReward(self:ContractState,account:ContractAddress) -> u256{
  let caller = get_caller_address();
  let stake_status:bool = self.staker.read(caller).status;
    let stake_amount = self.staker.read(caller).amount;
    let stake_time:u64 = self.staker.read(caller).timeStaked;
  if stake_status == false{
    return 0;
  }
  let reward_per_month = (stake_amount * 10);
  let time = get_block_timestamp() - stake_time;
  let reward = (reward_per_month * time.into() * 1000) / minStakeTime.into();
  return reward;

}

#[view]
// getUserBalance
fn getUserBalance(self:@ContractState) -> u256{
let caller:ContractAddress = get_caller_address();
return self.staker.read(caller).amount;
}

#[view]
// getStakeDetailsByAddress
fn getStakeDetailsByAddress(self: @ContractState, account:ContractAddress) -> StakeDetail{
    return self.staker.read(account);
}


}