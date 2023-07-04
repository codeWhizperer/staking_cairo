use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<ContractState>{
    fn get_name(self: @ContractState) -> felt252;
    fn get_symbol(self:@ContractState) -> felt252;
    fn get_decimals(self:@ContractState) -> u8;
    fn get_total_supply(self:@ContractState) -> u256;
    fn get_balance_of(self:@ContractState, account:ContractAddress) -> u256;
    fn approve(ref self:ContractState, spender:ContractAddress, amount:u256) -> bool;
    fn allowance(self:@ContractState, spender:ContractAddress, owner:ContractAddress) -> u256;
    fn transfer(ref self: ContractState, recipient:ContractAddress, amount:u256) -> bool;
    fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient:ContractAddress, amount:u256) -> bool;
        fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: u256);
    fn decrease_allowance(
        ref self: ContractState, spender: ContractAddress, subtracted_value: u256
    );
}



