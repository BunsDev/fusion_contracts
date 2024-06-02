# Fusion - Contracts

![Made-With-Solidity](https://img.shields.io/badge/MADE%20WITH-SOLIDITY-000000.svg?colorA=222222&style=for-the-badge&logoWidth=14&logo=solidity)
![Made-With-ChainLink](https://img.shields.io/badge/MADE%20WITH-ChainLink-fef8f4.svg?colorA=222222&style=for-the-badge&logoWidth=14)

> Fusion is a multi-chain smart contract wallet that leverages ChainLink Functions and zero-knowledge proofs for cross-chain deployments and authentication. It also uses Avalanche Sub-Chain to provide unified Gas Credits and indexing transactions.

These are the solidity smart contracts used in the _[getFusion.tech](https://getFusion.tech/)_ hackathon project at [Chainlink BlockMagic Hackathon 2024](https://chain.link/hackathon).

> Active ChainLink Functions Subscription - [Fusion-Backend](https://github.com/FusionWallet/fusion_backend)

## Deployments

- **Avalanche fuji(Base-Chain)**

  - Fusion - [0x3ED5EccFFD1afE3172A9DEeDeD795b479f95a841](https://testnet.routescan.io/address/0x3ED5EccFFD1afE3172A9DEeDeD795b479f95a841)
  - Fusion Forwarder - [0x1Baf9847E474b1B548545b92F5186097DB4E77B1](https://testnet.routescan.io/address/0x1Baf9847E474b1B548545b92F5186097DB4E77B1)
  - Factory Forwarder - [0x64d82895F0F60B35c28e567d7a576Bad8EBaf369](https://testnet.routescan.io/address/0x64d82895F0F60B35c28e567d7a576Bad8EBaf369)
  - Fusion Proxy Factory - [0xf76B9F4D05189A968321AB9285fc66B0f3f76ab8](https://testnet.routescan.io/address/0xf76B9F4D05189A968321AB9285fc66B0f3f76ab8)
  - Fusion Vault - [0x3D00e49fCee24826fa677fadb2e0625293369972](https://testnet.routescan.io/address/0x3D00e49fCee24826fa677fadb2e0625293369972)

- **Polygon Amoy(Side-Chain)**

  - Fusion - [0xd8c7f8D24d32C81641CBA0A294E35C22fcF38dFd](https://amoy.polygonscan.com/address/0xd8c7f8d24d32c81641cba0a294e35c22fcf38dfd)
  - Fusion Forwarder - [0x843fE00Bec83abE55B5A2a02826b0B35e11f6d6d](https://amoy.polygonscan.com/address/0x843fe00bec83abe55b5a2a02826b0b35e11f6d6d)
  - Factory Forwarder - [0x15335B81E1919E82bEc4Cde414Db53E57f103fDd](https://amoy.polygonscan.com/address/0x15335b81e1919e82bec4cde414db53e57f103fdd)
  - Fusion Proxy Factory - [0xA40d26b6598EE91939CB4871121051B528111417](https://amoy.polygonscan.com/address/0xa40d26b6598ee91939cb4871121051b528111417)
  - Fusion Vault - [0x92A8952893e140d5c0f7d3dFbFd189FbBbF3A4FA](https://amoy.polygonscan.com/address/0x92a8952893e140d5c0f7d3dfbfd189fbbbf3a4fa)

- **Base Sepolia(Side-Chain)**

  - Fusion - [0xf1E842Ef0774dBE7CaF7f0F95d1315fD834d2a4b](https://sepolia.basescan.org/address/0xf1E842Ef0774dBE7CaF7f0F95d1315fD834d2a4b)
  - Fusion Forwarder - [0x2aa4c97688f340C8A2bDE2016b16dEFDC259834D](https://sepolia.basescan.org/address/0x2aa4c97688f340C8A2bDE2016b16dEFDC259834D)
  - Factory Forwarder - [0x8487F6630510A00bFACd9Fe701700F193F52C04F](https://sepolia.basescan.org/address/0x8487f6630510a00bfacd9fe701700f193f52c04f)
  - Fusion Proxy Factory - [0x2EF41EC23021bD5aBa53C6599D763e89A897Acad](https://sepolia.basescan.org/address/0x2ef41ec23021bd5aba53c6599d763e89a897acad)
  - Fusion Vault - [0x294d7bcC3A6eCB725aE877E4e9a520bEB50E802C](https://sepolia.basescan.org/address/0x294d7bcC3A6eCB725aE877E4e9a520bEB50E802C)

- **Optimism Sepolia(Side-Chain)**

  - Fusion - [0xF768fA09b378200811eE0CFe6DeD7B2E830202E5](https://sepolia-optimism.etherscan.io/address/0xF768fA09b378200811eE0CFe6DeD7B2E830202E5)
  - Fusion Forwarder - [0x2020B832f19BCF6aC3ae8073Fe1C8e06140c2306](https://sepolia-optimism.etherscan.io/address/0x2020B832f19BCF6aC3ae8073Fe1C8e06140c2306)
  - Factory Forwarder - [0xADcCA523443cf9e9Cfda181872fB20D286C5ebBc](https://sepolia-optimism.etherscan.io/address/0xadcca523443cf9e9cfda181872fb20d286c5ebbc)
  - Fusion Proxy Factory - [0x1FAd28Ec81C7e9DF883bf05aA1a42aBe4684904E](https://sepolia-optimism.etherscan.io/address/0x1FAd28Ec81C7e9DF883bf05aA1a42aBe4684904E)
  - Fusion Vault - [0x8C76A41a3bF34624589f1fB59A42836C27Ad2a76](https://sepolia-optimism.etherscan.io/address/0x8C76A41a3bF34624589f1fB59A42836C27Ad2a76)

- **Fusion(Sub-chain)**

  - Indexer - 0x2fAF5856C60C14730fd7594684C2C7d52097f440
  - IndexerProxyFactory - 0x50F1bbb486D62921eD9cE411c6b85Ec0B73D9130
  - BalanceHandler - 0xf1E842Ef0774dBE7CaF7f0F95d1315fD834d2a4b

  #

> **Pre-requisites:**
>
> - Setup Node.js v18+ (recommended via [nvm](https://github.com/nvm-sh/nvm) with `nvm install 18`)
> - Install [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
> - Clone this repository

```bash
# Install dependencies
npm install

# fill environments
cp .env.example .env
```

## Development

```bash
# Compile all the contracts
npx hardhat compile

# Deploy on Avalanche Fuji, Check hardhat.config.js to check or add supported chains
npx hardhat run --network fuji scripts/deploy.js
```
