
#[starknet::contract]
mod Token {

////////////////////////////
// LIBRARY IMPORTS
////////////////////////////
use starknet::ContractAddress;
use new_syntax::interfaces::IERC20;
use new_syntax::interfaces::IERC20DispatcherTrait;
use new_syntax::interfaces::IERC20Dispatcher;
use core::zeroable::Zeroable;
use starknet::get_caller_address;

////////////////////
//STORAGE
///////////////////
    #[storage]
    struct Storage{
        _name:felt252,
        _symbol:felt252,
        _decimals:u8,
        _total_supply:u256,
        _balances:LegacyMap::<ContractAddress, u256>,
        _allowance:LegacyMap::<(ContractAddress, ContractAddress), u256>
    }

    ///////////////////
    // EVENTS
    ///////////////////
#[event]
#[derive(Drop, starknet::Event)]
enum Event {
Transfer: Transfer,
Approval:Approval
}

#[derive(Drop, starknet::Event)]
 struct Transfer {
    sender:ContractAddress,
    recipient:ContractAddress,
    amount: u256
 }

 #[derive(Drop, starknet::Event)]
 struct Approval {
    owner:ContractAddress,
    spender:ContractAddress,
    amount: u256
 }
    #[external(v0)]
    impl IERC20Impl of IERC20<ContractState>{
        fn get_name(self:@ContractState) -> felt252{
        return  self._name.read();
        }

        fn get_symbol (self:@ContractState) -> felt252{
            return self._symbol.read();
        }

        fn get_decimals(self: @ContractState) -> u8{
            return self._decimals.read();
        }
        fn get_total_supply(self: @ContractState) -> u256{
            return self._total_supply.read();
        }
        fn get_balance_of(self: @ContractState, account:ContractAddress) -> u256{
            return self._balances.read(account);
        }

        fn allowance(self: @ContractState, spender:ContractAddress, owner:ContractAddress) -> u256{
        return self._allowance.read((spender, owner));
        }
        fn transfer(ref self: ContractState, recipient:ContractAddress, amount:u256) -> bool {
            let caller = get_caller_address();
            self._transfer(caller, recipient, amount);
            return true;
        }
    
    fn transfer_from(ref self:ContractState, sender:ContractAddress, recipient:ContractAddress, amount:u256) -> bool{
        let caller = get_caller_address();
        self.spend_allowance(sender, recipient,amount);
        self._transfer(sender,recipient,amount);
        return true;
    }

    fn approve(ref self: ContractState, spender:ContractAddress, amount:u256) -> bool{
        let caller = get_caller_address();
        self._approve(caller, spender, amount);
        return true;
    }
    fn increase_allowance(ref self:ContractState,  spender:ContractAddress, added_value:u256) {
        let caller = get_caller_address();
        self._approve(caller, spender, self._allowance.read((caller,spender)) + added_value);
    }

        fn decrease_allowance(ref self:ContractState,  spender:ContractAddress, subtracted_value:u256) {
        let caller = get_caller_address();
        self._approve(caller, spender, self._allowance.read((caller,spender)) + subtracted_value);
    }
    }

#[generate_trait]
 impl StorageImpl of StorageTrait{
   fn _transfer(ref self: ContractState, sender:ContractAddress, recipient:ContractAddress, amount:u256) -> bool{
    assert(!sender.is_zero(), 'ERC20: transfer_to_zero');
    assert(!recipient.is_zero(), 'ERC20: transfer_to_zero');
    self._balances.write(sender, self._balances.read(sender) - amount);
    self._balances.write(recipient, self._balances.read(recipient) + amount);
   self.emit(Event::Transfer(Transfer{sender, recipient, amount}));
    return true;
   }

   fn _approve(ref self: ContractState, owner:ContractAddress, spender:ContractAddress, amount:u256) -> bool{
    assert(!spender.is_zero(), 'ERC20: approve zero');
    self._allowance.write((owner, spender), amount);
    self.emit(Event::Approval(Approval{owner, spender, amount}));
    return true;
   }
   fn spend_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let current_allowance = self._allowance.read((owner, spender));
            let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
            let is_unlimited_allowance = current_allowance.low == ONES_MASK
                && current_allowance.high == ONES_MASK;
            if !is_unlimited_allowance {
                self._approve(owner, spender, current_allowance - amount);
            }
        }
 }


}