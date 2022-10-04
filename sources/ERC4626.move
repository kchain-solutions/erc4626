module ERC4626::vault{
    use aptos_framework::account;
    use aptos_framework::signer;
    use aptos_framework::coin::{Self, MintCapability, FreezeCapability, BurnCapability};
    use aptos_framework::string::{utf8};
    use aptos_framework::managed_coin;
    use std::error;
    use std::debug;
    use aptos_std::type_info;

    const VAULT_NOT_REGISTERED: u64 = 1;
    const NO_ADMIN_PERMISSION: u64 = 2;
    const COIN_ONE_NOT_REGISTERED: u64 = 3;
    const COIN_TWO_NOT_EXIST:u64 = 4;
    const VAULT_REGISTERED: u64 = 5;
    const INSUFFICIENT_AMOUNT: u64 = 6;

    const MODULE_ADDRESS: address = @ERC4626;

    struct VaultInfo<phantom CoinType, phantom YCoinType> has key{
        signer_capability: account::SignerCapability,
        addr: address,
        mint_cap: MintCapability<YCoinType>,
        freeze_cap: FreezeCapability<YCoinType>,
        burn_cap: BurnCapability<YCoinType>
    }

    public entry fun initialize_new_vault<CoinType, YCoinType>(contract_owner:&signer, y_coin_name:vector<u8>, y_coin_symbol:vector<u8>){
        
        let contract_owner_addr = signer::address_of(contract_owner);

        assert!(contract_owner_addr == MODULE_ADDRESS, error::unauthenticated(NO_ADMIN_PERMISSION));
        assert!(coin::is_account_registered<CoinType>(contract_owner_addr), error::not_found(COIN_ONE_NOT_REGISTERED));
        assert!(!exists<VaultInfo<CoinType, YCoinType>>(contract_owner_addr), error::already_exists(VAULT_REGISTERED));

        let (vault_signer, vault_signer_capability) = account::create_resource_account(contract_owner, y_coin_name);
        let vault_addr = signer::address_of(&vault_signer);
        managed_coin::register<CoinType>(&vault_signer);

        //assert!(exists<YCoinType>(contract_owner_addr), COIN_TWO_NOT_REGISTERED);
        
        //Create YCoin
        let ad = coin_address<YCoinType>();
        debug::print(&ad);
        debug::print(&contract_owner_addr);

        //move_to(contract_owner, ManagedCoin{});
        
        let ( burn_cap, freeze_cap, mint_cap) = coin::initialize<YCoinType>(contract_owner, utf8(y_coin_name), utf8(y_coin_symbol), 0, true);

        debug::print(&b"3");

        //Move
        move_to(contract_owner, VaultInfo<CoinType, YCoinType>{
            signer_capability: vault_signer_capability,
            addr: vault_addr,
            mint_cap,
            freeze_cap,
            burn_cap,
        });

        debug::print(&b"4");


    }

    fun coin_address<CoinType>(): address {
        let type_info = type_info::type_of<CoinType>();
        type_info::account_address(&type_info)
    }

    public entry fun deposit<CoinType, YCoinType>(user: &signer, amount:u64) acquires VaultInfo{
        let user_addr = signer::address_of(user);
        let vault_info = borrow_global<VaultInfo<CoinType, YCoinType>>(MODULE_ADDRESS);
        assert!(!exists<VaultInfo<CoinType, YCoinType>>(MODULE_ADDRESS), error::not_found(VAULT_NOT_REGISTERED));
        register<CoinType>(user);
        register<YCoinType>(user);
        assert!(coin::balance<CoinType>(user_addr) >= amount,error::out_of_range(INSUFFICIENT_AMOUNT));
        coin::transfer<CoinType>(user, vault_info.addr, amount);
        let coins_minted = coin::mint<YCoinType>(amount, &vault_info.mint_cap);
        coin::deposit(user_addr, coins_minted);
    }

    public entry fun withdraw(){

    }

    public entry fun redeem(){

    }

    public entry fun total_asset(){

    }

    fun register<CoinType>(account: &signer){
        if (!coin::is_account_registered<CoinType>(signer::address_of(account))){
            coin::register<CoinType>(account);
        };
    }
}