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

## OnChain Tutorial

The logic of the smart contract is contained in **ERC4626.move**. ERC4626 espone dei metodi generici per la creazione di vaults.
The concrete instance that allows interaction with the contract is achieved through **AptosVault.move**.

#### Publishing ERC4626 contract
```aptos move publish --package-dir erc4626/ERC4626 --named-addresses ERC4626=default ```

```json
{
  "Result": {
    "transaction_hash": "0x547221f3331cf54b631d15ea8af6c59163535b3df5049b20c6e479020b5f2454",
    "gas_used": 2455,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 0,
    "success": true,
    "timestamp_us": 1665137102663405,
    "version": 10528570,
    "vm_status": "Executed successfully"
  }
}
```

#### Publishing AptosVault
The aptos vault is the concrete instance of the ERC4626

edit the AptosVaul toml file with the address of the ERC4626 just published

```toml
[package]
name="AptosVault"
version="0.1.0"

[addresses]
AptosVault="_"
ERC4626="0x932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49"

[dependencies]
ERC4626= { local = "../ERC4626/" }
```

```aptos move publish --package-dir erc4626/AptosVault --named-addresses ERC4626=default --named-addresses AptosVaut=default```

```json
{
  "Result": {
    "transaction_hash": "0x9fec2646016d4a00b4bb28817aed57f5bb9528920aaa82e3c66ce7cfba73bd35",
    "gas_used": 1376,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 1,
    "success": true,
    "timestamp_us": 1665137529572501,
    "version": 10537334,
    "vm_status": "Executed successfully"
  }
}
```

### Create vault instance
```aptos move run --function-id 932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49::ConcreteVault::initialiaze_vault --args string:yAptosCoin string:yAPT u64:5000```

```json
{
  "Result": {
    "transaction_hash": "0x6be20bbe91c4b19927635d20a3943b7ac35cbfae8fffd24112d1fa088e8bcef1",
    "gas_used": 461,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 2,
    "success": true,
    "timestamp_us": 1665137964471323,
    "version": 10547898,
    "vm_status": "Executed successfully"
  }
}
```

### Deposit example
```aptos move run --function-id 932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49::ConcreteVault::deposit --args string:yAptosCoin string:yAPT u64:1000000```

```json
{
  "Result": {
    "transaction_hash": "0xba5287bb947d0762c5f08322a26189bca75f3124a4e3a97f423bf91f0b2330ce",
    "gas_used": 519,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 4,
    "success": true,
    "timestamp_us": 1665138202287008,
    "version": 10553487,
    "vm_status": "Executed successfully"
  }
}
```

### Trasfer example
```aptos move run --function-id 932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49::ConcreteVault::transfer --args u64:1111```

```json
{
  "Result": {
    "transaction_hash": "0x392aae4f18a31f69ebba8849e15bbb8499ea0ce13a3e39011b573cc589820438",
    "gas_used": 465,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 3,
    "success": true,
    "timestamp_us": 1665138117925874,
    "version": 10551808,
    "vm_status": "Executed successfully"
  }
}
```

### Withdraw example
```aptos move run --function-id 932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49::ConcreteVault::withdraw --args u64:20000```

```json
{
  "Result": {
    "transaction_hash": "0x9fbd267ed2fb9a5178ded9704a7f43a05235dd85207c84e3d2236d891f3bee1d",
    "gas_used": 520,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 5,
    "success": true,
    "timestamp_us": 1665138249738149,
    "version": 10554542,
    "vm_status": "Executed successfully"
  }
}
```

### Redeem example
```aptos move run --function-id 932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49::ConcreteVault::redeem --args u64:33300```

```json
{
  "Result": {
    "transaction_hash": "0xb0418112eccdd18f6d2c7ea35e4df4c643b6f7e92b27b2966c686f3cf39c0bf9",
    "gas_used": 518,
    "gas_unit_price": 100,
    "sender": "932d148b45216030dd27a72b1b053db27987c5b93635c40c0852e5be508b8a49",
    "sequence_number": 6,
    "success": true,
    "timestamp_us": 1665138301499872,
    "version": 10555684,
    "vm_status": "Executed successfully"
  }
}
```