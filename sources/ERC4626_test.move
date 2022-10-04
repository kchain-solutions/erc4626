#[test_only]
module ERC4626::VaultTest{
    //use std::error;
    use aptos_framework::account;
    use aptos_framework::signer;
    use aptos_framework::managed_coin;
    use aptos_framework::coin::{Self, MintCapability, BurnCapability};
    use aptos_framework::aptos_coin::{Self, AptosCoin};

    //use std::debug;

    use ERC4626::vault;

    const YAPTOSCOIN_NOT_CREATED: u64 = 1;

    const CONTRACT_OWNER: address = @ERC4626;

    struct YAptosCoin has key {}
    struct ZAptosCoin has key {}

    struct AptosCoinTest has key{
        mint_cap: MintCapability<AptosCoin>,
        burn_cap: BurnCapability<AptosCoin>
    }

    #[test (contract_owner=@ERC4626, user=@0x234, aptos_framework=@aptos_framework)]
    public fun initialiaze_test(contract_owner: &signer, user: &signer, aptos_framework:&signer){
        let (y_coin_name, y_coin_symbol): (vector<u8>, vector<u8>) = (b"yAptos", b"yAPT");
        let (z_coin_name, z_coin_symbol): (vector<u8>, vector<u8>) = (b"zAptos", b"zAPT");

        account::create_account_for_test(signer::address_of(contract_owner));
        account::create_account_for_test(signer::address_of(user));
        mint_aptos(contract_owner, user, aptos_framework);
        vault::initialize_new_vault<AptosCoin, YAptosCoin>(contract_owner, y_coin_name, y_coin_symbol);
        vault::initialize_new_vault<AptosCoin, ZAptosCoin>(contract_owner, z_coin_name, z_coin_symbol);
    }

    #[test_only]
    fun mint_aptos(contract_owner: &signer, user: &signer, aptos_framework: &signer){
        let admin_addr = signer::address_of(contract_owner);
        let user_addr = signer::address_of(user);

        let ( burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        let coins_minted_admin = coin::mint<AptosCoin>(1000000000, &mint_cap);
        let coins_minted_user = coin::mint<AptosCoin>(1000000000, &mint_cap);

        if (!coin::is_account_registered<AptosCoin>(admin_addr)){
	      managed_coin::register<AptosCoin>(contract_owner);
        };
        if (!coin::is_account_registered<AptosCoin>(user_addr)){
	      managed_coin::register<AptosCoin>(user);
        };

        coin::deposit<AptosCoin>(admin_addr, coins_minted_admin);
        coin::deposit<AptosCoin>(user_addr, coins_minted_user);

        move_to(contract_owner, AptosCoinTest{
            mint_cap,
            burn_cap
        });
    }

    


   


}