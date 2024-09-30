# InfinityStacks

InfinityStacks leverages sbtc synthetic tokens on the Stacks blockchain to provide a transformative DeFi platform that offers:

Cross-Chain Trading - Seamless transactions across diverse cryptocurrencies.
Enhanced Liquidity - Access to deeper liquidity pools for improved trade execution.
Profitable Staking - Innovative collateral staking mechanisms that yield substantial returns.

## Repository Structure

This repository is organized into several key directories:

### `contracts`

Contains the Clarity smart contracts that power the platform.

- **Settings**: Configuration files for different networks ( Devnet, Testnet).
- **Contracts**: The core smart contracts (`infinitystacks.clar`, `mock-price-feed.clar`, and more).
- **Deployments**: YAML files detailing deployment plans for various environments.

### `frontend`

The frontend directory houses the Next.js-based web application for interacting with the InfinityStacks platform.

- **App**: Contains the main layout, styling, and page components. The `trade` sub-directory features components specific to trading functionalities.
- **Configuration**: Files like `next.config.js` and `tailwind.config.ts` for project setup and styling.

### `scripts`

Scripts folder containing `populate-onchain-data.js` script that populates on-chain price data and updates it every 2 minutes.

## Getting Started

In order to run InfinityStacks, you need the following software to be installed:

- [clarinet](https://github.com/hirosystems/clarinet)
- [yarn](https://yarnpkg.com/)
- [node.js](https://nodejs.org/en/download)
- [Docker](https://www.docker.com/)

Once these dependencies are on your computer, clone this repository. Then, navigate into the project root directory.

```bash
cd InfinityStacks
```

### Running the local devnet

If Docker is not running, boot Docker up. Then, navigate to the `contracts` directory:

```bash
cd contracts
```

Install dependencies:

```bash
yarn
```

And run the local stacks devnet:

```bash
clarinet devnet start
```

This process may take some time on the first try. Once your local devnet has started and block 5 is mined, navigate to the scripts folder in a new terminal window:

```bash
cd InfinityStacks/scripts
```

Install dependencies:

```bash
yarn
```

And run the on-chain data script:

```bash
node ./populate-onchain-data.js
```

You should see some output like this:

```
Adding mock feeds on-chain (nonce: 5).
33a6d748793c2db48b9f3eda3e7951e2ffd54fa44b47ec6c22d7e68d9deeee93 {
  txid: '33a6d748793c2db48b9f3eda3e7951e2ffd54fa44b47ec6c22d7e68d9deeee93'
}
Setting supported feeds for InfinityStacks on-chain (nonce: 6).
89071c42b00778d3434066eb1081a16c981b1288d19883c49f7c0775767a0237 {
  txid: '89071c42b00778d3434066eb1081a16c981b1288d19883c49f7c0775767a0237'
}
```

You can double check in your local devnet console that two new transactions have been added to the mempool and are being processed.

Once you have populated on-chain data in your local stacks devnet instance, navigate to the frontend directory:

```bash
cd InfinityStacks/client
```

Install dependencies:

```bash
yarn
```

And run the frontend:

```bash
yarn dev
```

You should then be able to navigate to `localhost:3000` and start using the Dapp!

## Contributing

Contributions to InfinityStacks are welcome! Please get in touch or open a pull request to contribute.
