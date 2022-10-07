module ERC4626::aptos_vault{

    use ERC4626::vault;
    use aptos_framework::aptos_coin::{AptosCoin};

    struct YAptosCoin has key {}

    public entry fun initialiaze_vault(contract_owner: &signer, coin_name: vector<u8>, coin_symbol: vector<u8>){
        vault::initialize_new_vault<AptosCoin, YAptosCoin>(contract_owner, coin_name, coin_symbol);
    }

    public entry fun deposit(user: &signer, amount: u64){
        vault::deposit<AptosCoin, YAptosCoin>(user, amount);
    }

    public entry fun withdraw(user: &signer, assets: u64){
        vault::withdraw<AptosCoin, YAptosCoin>(user, assets);
    }

    public entry fun redeem(user: &signer, shares: u64){
        vault::redeem<AptosCoin, YAptosCoin>(user, shares);
    }

    public entry fun transfer(user: &signer, assets: u64){
        vault::transfer<AptosCoin, YAptosCoin>(user, assets);
    }
}