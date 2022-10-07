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
```
```
This function accept as input a share amount value. The user will receive asset coin proportional to his share partecipation.

### Transfer
```public entry fun transfer<CoinType, YCoinType>(user: &signer, asset_amount:u64) acquires VaultEvents, VaultInfo```
This method allow to transfer on the vault asset without receive shares back.

### Cotract deployed
```json
{
  "Result": {
    "transaction_hash": "0xf91d53ce91e1e7bcfc3cb961db407a028da54447acaa5599034967ab1b4ed9b5",
    "gas_used": 2909,
    "gas_unit_price": 100,
    "sender": "f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800",
    "sequence_number": 0,
    "success": true,
    "timestamp_us": 1665088147757279,
    "version": 9428460,
    "vm_status": "Executed successfully"
  }
}
```
#### Init aptos_vault
```aptos move run --function-id f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800::aptos_vault::initialiaze_vault --args string:yAptos string:yAPT u64:5000``` 

Transaction example
```json
```

#### Deposit
```aptos move run --function-id f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800::aptos_vault::deposit --args u64:10000```

Transaction example
```json
{
  "Result": {
    "transaction_hash": "0xc844df7eba641adc89d331b0690e7439f2040df40f1b6658aaa39cf7cfa71c11",
    "gas_used": 576,
    "gas_unit_price": 100,
    "sender": "f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800",
    "sequence_number": 2,
    "success": true,
    "timestamp_us": 1665128310974239,
    "version": 10229208,
    "vm_status": "Executed successfully"
  }
}
```
#### Withdraw
```aptos move run --function-id f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800::aptos_vault::withdraw --args u64:500```

```json
{
  "Result": {
    "transaction_hash": "0xea4741444e11f94c87a02be161d6f599c30b8bb0a871466269251a746976346e",
    "gas_used": 514,
    "gas_unit_price": 100,
    "sender": "f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800",
    "sequence_number": 3,
    "success": true,
    "timestamp_us": 1665128643523434,
    "version": 10240753,
    "vm_status": "Executed successfully"
  }
}
```

#### Transfer 
```aptos move run --function-id f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800::aptos_vault::transfer --args u64:17899```

```json
{
  "Result": {
    "transaction_hash": "0x33783bba016efc7661b1222d1992586aabbd6aab59ab50828bea0127247e2233",
    "gas_used": 358,
    "gas_unit_price": 100,
    "sender": "f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800",
    "sequence_number": 4,
    "success": true,
    "timestamp_us": 1665128685821998,
    "version": 10242087,
    "vm_status": "Executed successfully"
  }
}
```

#### Redeem
```aptos move run --function-id f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800::aptos_vault::redeem --args u64:799```

```json
{
  "Result": {
    "transaction_hash": "0xaf5e1738b8fe9c9a23367e0dc84a4afcca1d7149ee2c54b6163383a0d484887f",
    "gas_used": 513,
    "gas_unit_price": 100,
    "sender": "f7af07e1e1186a1484fb7043f5a36048af49e941d515a8cf049e939d56a84800",
    "sequence_number": 5,
    "success": true,
    "timestamp_us": 1665128729962474,
    "version": 10243493,
    "vm_status": "Executed successfully"
  }
}
```