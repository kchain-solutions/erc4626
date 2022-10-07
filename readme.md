# ERC4626

ERC-4626 is a standard to optimize and unify the technical parameters of yield-bearing vaults. It provides a standard API for tokenized yield-bearing vaults that represent shares of a single underlying ERC-20 token. ERC-4626 also outlines an optional extension for tokenized vaults utilizing ERC-20, offering basic functionality for depositing, withdrawing tokens and reading balances. …” [4]

All EIP-4626 tokenized Vaults must implement EIP-20 to represent shares. If a Vault is to be non-transferrable, it may revert on calls to transfer or transferFrom. The EIP-20 operations balanceOf, transfer, totalSupply, etc. operate on the Vault “shares” which represent a claim to ownership on a fraction of the Vault’s underlying holdings.

All EIP-4626 tokenized Vaults must implement EIP-20’s optional metadata extensions. The name and symbol functions sholud reflect the underlying token’s name and symbol in some way.

EIP-4626 tokenized Vaults may implement EIP-2612 to improve the UX of approving shares on various integrations.


 Definitions

* **Asset**: The underlying token managed by the Vault. Has units defined by the corresponding EIP-20 contract.
* **Share**: The token of the Vault. Has a ratio of underlying assets exchanged on mint/deposit/withdraw/redeem (as defined by the Vault).
* **Fee**: An amount of assets or shares charged to the user by the Vault. Fees can exists for deposits, yield, AUM, withdrawals, or anything else prescribed by the Vault.
* **Slippage**: Any difference between advertised share price and economic realities of deposit to or withdrawal from the Vault, which is not accounted by fees.


## Introduction 

The contract is inspired to the Ethereum standard [ERC4626](https://ethereum.org/en/developers/docs/standards/tokens/erc-4626)
but considering the peculiarities of Aptos blockchain.

Here is a [solidity example implementation](https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol) 

```rust
  struct VaultInfo<phantom CoinType, phantom YCoinType> has key{
        signer_capability: account::SignerCapability,
        addr: address,
        mint_cap: MintCapability<YCoinType>,
        freeze_cap: FreezeCapability<YCoinType>,
        burn_cap: BurnCapability<YCoinType>
    }
```

Each vault is uniquely defined from the couple ```<phantom CoinType, phantom YCoinType>```
The **CoinType**: the type which represents the asset the user wants deposit in the vault.
The **YCoinType**: represents the share coin that allows to withdraw/redeem the asset.

The contract allow to handle different vaults with a single account.

## Methods

### Initialize new vault
```public entry fun initialize_new_vault<CoinType, YCoinType>(contract_owner:&signer, y_coin_name:vector<u8>, y_coin_symbol:vector<u8>)```

This methods allow to init a new vault and initialize the contract's resources.

### Deposit
```public entry fun deposit<CoinType, YCoinType>(user: &signer, asset_amount:u64) acquires VaultInfo, VaultSharesSupply, VaultEvents```
The method allows the user to deposit asset and receive back shares 1:1 of the asset deposited.

### Withdraw
```public entry fun withdraw<CoinType, YCoinType>(user: &signer, assets_amount: u64) acquires VaultInfo, VaultSharesSupply, VaultEvents```
This function accept as input the asset amount the user wants to withdraw. If the user has sufficient shares to withdraw the asset amount the method will succeed.

### Redeem
```public entry fun redeem<CoinType, YCoinType>(user: &signer, shares_amount: u64) acquires VaultInfo, VaultEvents, VaultSharesSupply```
This function accept as input a share amount value. The user will receive asset coin proportional to his share partecipation.

### Transfer
```public entry fun transfer<CoinType, YCoinType>(user: &signer, asset_amount:u64) acquires VaultEvents, VaultInfo```
This method allow to transfer on the vault asset without receive shares back.

### Cotract deployed
```json
{
  "Result": {
    "transaction_hash": "0xc9e5c4da4f79eb9fbbc531190dc1c8f3fcf87ae846112d156462aa8ce8064346",
    "gas_used": 2951,
    "gas_unit_price": 100,
    "sender": "fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1",
    "sequence_number": 0,
    "success": true,
    "timestamp_us": 1665131997338327,
    "version": 10368377,
    "vm_status": "Executed successfully"
  }
}
}
```
#### Init aptos_vault
```aptos move run --function-id fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1::AptosVault::initialiaze_vault --args string:yAptos string:yAPT u64:5000``` 

Transaction example
```json
{
  "Result": {
    "transaction_hash": "0x4ea0d9b0e6eb952620f7ece09cd631866ed60893650e4405a3624b16304982ca",
    "gas_used": 460,
    "gas_unit_price": 100,
    "sender": "fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1",
    "sequence_number": 1,
    "success": true,
    "timestamp_us": 1665132163972206,
    "version": 10374348,
    "vm_status": "Executed successfully"
  }
}
```

#### Deposit
```aptos move run --function-id fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1::AptosVault::deposit --args u64:10000```

Transaction example
```json
{
  "Result": {
    "transaction_hash": "0xc69c6a3b150205ac9ba2efc170edb617d1cd65ef94bc69b45b93a45cfac1d3ca",
    "gas_used": 581,
    "gas_unit_price": 100,
    "sender": "fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1",
    "sequence_number": 2,
    "success": true,
    "timestamp_us": 1665132216831974,
    "version": 10376256,
    "vm_status": "Executed successfully"
  }
}
```
#### Withdraw
```aptos move run --function-id fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1::AptosVault::withdraw --args u64:500```
Transaction example
```json
{
  "Result": {
    "transaction_hash": "0xf1ebc42b346326c55541785ee8c95f1ad27d2a15543698469bf9bd7902206572",
    "gas_used": 519,
    "gas_unit_price": 100,
    "sender": "fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1",
    "sequence_number": 3,
    "success": true,
    "timestamp_us": 1665132247983205,
    "version": 10377203,
    "vm_status": "Executed successfully"
  }
}
```

#### Transfer 
```aptos move run --function-id fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1::AptosVault::transfer --args u64:17899```
Transaction example
```json
{
  "Result": {
    "transaction_hash": "0xf7a9c3da644f03fe5b1f9f839ee42e47b3853069b93c2333bb0061ce8de13697",
    "gas_used": 358,
    "gas_unit_price": 100,
    "sender": "fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1",
    "sequence_number": 4,
    "success": true,
    "timestamp_us": 1665132300480670,
    "version": 10378732,
    "vm_status": "Executed successfully"
  }
}
```

#### Redeem
```aptos move run --function-id fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1::AptosVault::redeem --args u64:799```
Transaction example
```json
{
  "Result": {
    "transaction_hash": "0xd1f89c6e689c04ae1242a4645d4af981dc0a70cd4cc0505bc4b4a07f439ffc7a",
    "gas_used": 518,
    "gas_unit_price": 100,
    "sender": "fdee3411eaf723b63f439bb7d026dd3abd3b6017007e6a2f87b0e7b1e30a7ca1",
    "sequence_number": 5,
    "success": true,
    "timestamp_us": 1665132334705489,
    "version": 10379725,
    "vm_status": "Executed successfully"
  }
}
```