module ERC4626::vault{
    use aptos_framework::account;
    use aptos_framework::signer;
    use aptos_framework::coin::{Self, MintCapability, FreezeCapability, BurnCapability};
    use aptos_framework::string::{Self, String, utf8};
    use aptos_framework::managed_coin;
    use aptos_framework::event::{Self, EventHandle};
    //use std::debug;
    use aptos_std::type_info;

    const VAULT_NOT_REGISTERED: u64 = 1;
    const NO_ADMIN_PERMISSION: u64 = 2;
    const COIN_ONE_NOT_REGISTERED: u64 = 3;
    const COIN_TWO_NOT_EXIST:u64 = 4;
    const VAULT_ALREADY_REGISTERED: u64 = 5;
    const INSUFFICIENT_AMOUNT: u64 = 6;

    const MODULE_ADDRESS: address = @ERC4626;

    struct VaultInfo<phantom CoinType, phantom YCoinType> has key{
        signer_capability: account::SignerCapability,
        addr: address,
        mint_cap: MintCapability<YCoinType>,
        freeze_cap: FreezeCapability<YCoinType>,
        burn_cap: BurnCapability<YCoinType>
    }

    struct VaultEvents has key{
        deposit_event: EventHandle<DepositEvent>,
        withdraw_event: EventHandle<WithdrawEvent>
    }

    struct DepositEvent has drop, store{
        from: address,
        vault_name: String,
        from_coin_balance: u64,
        to_coin_balance: u64,
        from_coin_y_balance: u64,
        to_coin_y_balance:u64
    }

    struct WithdrawEvent has drop, store{
        from: address,
        vault_name: String,
        from_coin_balance: u64,
        to_coin_balance: u64,
        from_coin_y_balance: u64,
        to_coin_y_balance:u64
    }

    public entry fun initialize_new_vault<CoinType, YCoinType>(contract_owner:&signer, y_coin_name:vector<u8>, y_coin_symbol:vector<u8>){
        
        let contract_owner_addr = signer::address_of(contract_owner);

        assert!(contract_owner_addr == MODULE_ADDRESS, NO_ADMIN_PERMISSION);
        assert!(coin::is_account_registered<CoinType>(contract_owner_addr), COIN_ONE_NOT_REGISTERED);
        assert!(!exists<VaultInfo<CoinType, YCoinType>>(contract_owner_addr), VAULT_ALREADY_REGISTERED);

        let (vault_signer, vault_signer_capability) = account::create_resource_account(contract_owner, y_coin_name);
        let vault_addr = signer::address_of(&vault_signer);
        managed_coin::register<CoinType>(&vault_signer);
    
        let ( burn_cap, freeze_cap, mint_cap) = coin::initialize<YCoinType>(contract_owner, utf8(y_coin_name), utf8(y_coin_symbol), 0, true);

        move_to(contract_owner, VaultInfo<CoinType, YCoinType>{
            signer_capability: vault_signer_capability,
            addr: vault_addr,
            mint_cap,
            freeze_cap,
            burn_cap,
        });
    }

    fun register<CoinType>(account: &signer){
        if (!coin::is_account_registered<CoinType>(signer::address_of(account))){
            coin::register<CoinType>(account);
        };
    }


    public entry fun deposit<CoinType, YCoinType>(user: &signer, amount:u64) acquires VaultInfo, VaultEvents{
        let user_addr = signer::address_of(user);    
        assert!(exists<VaultInfo<CoinType, YCoinType>>(MODULE_ADDRESS), VAULT_NOT_REGISTERED);
        let vault_name = get_vault_name<CoinType, YCoinType>();
        let vault_info = borrow_global<VaultInfo<CoinType, YCoinType>>(MODULE_ADDRESS);
        initialize_vault_events<CoinType, YCoinType>(user);
        register<CoinType>(user);
        register<YCoinType>(user);
        let (from_coin_balance, from_coin_y_balance): (u64, u64) = get_coins_balance<CoinType, YCoinType>(user_addr);
        assert!(from_coin_balance >= amount, INSUFFICIENT_AMOUNT);
        coin::transfer<CoinType>(user, vault_info.addr, amount);
        let coins_minted = coin::mint<YCoinType>(amount, &vault_info.mint_cap);
        coin::deposit(user_addr, coins_minted);
        let (to_coin_balance, to_coin_y_balance): (u64, u64) = get_coins_balance<CoinType, YCoinType>(user_addr);
        event::emit_event(&mut borrow_global_mut<VaultEvents>(user_addr).deposit_event, DepositEvent{
            from: user_addr,
            vault_name,
            from_coin_balance,
            to_coin_balance,
            from_coin_y_balance,
            to_coin_y_balance
        });
    }

    fun initialize_vault_events<CoinType, YCoinType>(account: &signer) {
        if(!exists<VaultEvents>(signer::address_of(account))){
            move_to(account, VaultEvents{
                deposit_event: account::new_event_handle<DepositEvent>(account),
                withdraw_event: account::new_event_handle<WithdrawEvent>(account)
            });
        }; 
    }

    fun get_vault_name<CoinType, YCoinType>(): string::String{
        let cointype_name = get_struct_name<CoinType>();
        let ycointype_name = get_struct_name<YCoinType>();
        let separator = utf8(b"/");
        string::append(&mut cointype_name, separator);
        string::append(&mut cointype_name, ycointype_name);
        cointype_name
    }

    fun get_struct_name<S>(): string::String {
        let type_info = type_info::type_of<S>();
        let struct_name = type_info::struct_name(&type_info);
        utf8(struct_name)
    }

    public fun get_coins_balance<CoinType, YCoinType>(account_addr: address): (u64, u64){
        let coin_balance = coin::balance<CoinType>(account_addr);
        let coin_y_balance = coin::balance<YCoinType>(account_addr);
        (coin_balance, coin_y_balance)
    }

    public entry fun withdraw(){

    }

    public entry fun redeem(){

    }

    public entry fun total_asset(){

    }
}