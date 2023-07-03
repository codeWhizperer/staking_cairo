use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<ContractState>{
    fn name(self: @ContractState) -> felt252;
    fn symbol(self:@ContractState) -> felt252;
    fn decimals(self:@ContractState) -> u8;
    fn total_supply(self:@ContractState) -> u256;
    fn balance_of(self:@ContractState, account:ContractAddress) -> u256;
    fn approve(ref self:ContractState, spender:ContractAddress, amount:u256) -> bool;
    fn allowance(ref self:ContractState, spender:ContractAddress, owner:ContractAddress, amount:u256 ) -> u256;
    fn transfer(ref self: ContractState, to:ContractAddress, amount:u256) -> bool;
    fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient:ContractAddress, amount:u256) -> bool;
}



