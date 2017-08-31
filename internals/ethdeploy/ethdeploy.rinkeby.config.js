const SignerProvider = require('ethjs-provider-signer');
const sign = require('ethjs-signer').sign;

// Get Account JSON
/*
// Structure is as follows
const account = {
  privateKey: '0x...',
  address: '0x407d73d8a49eeb85d32cf465507dd71d507100c1',
};
*/
const account = require('../../../account.json');

// Setup Signer Provider Instance
const signerProvider = new SignerProvider('https://ropsten.infura.io', {
  signTransaction: (rawTx, cb) => cb(null, sign(rawTx, account.privateKey)),
  accounts: (cb) => cb(null, [account.address]),
});

// Main module
module.exports = (options) => ({ // eslint-disable-line
  entry: [
    './src/lib/environments.json',
    './src/contracts',
  ],
  output: {
    path: './src/lib/',
    filename: 'environments.json',
    safe: true,
  },
  module: {
    environment: {
      name: 'rinkeby',
      provider: signerProvider,
      defaultTxObject: {
        from: 0,
        gas: 3000001,
      },
    },
    preLoaders: [
      { test: /\.(json)$/, loader: 'ethdeploy-environment-loader', build: true },
    ],
    loaders: [
      {
        test: /\.(sol)$/,
        loader: 'ethdeploy-solc-loader',
        base: 'src/contracts',
        filterWarnings: true,
      },
    ],
    deployment: (deploy, contracts, done) => {
      deploy(contracts['OpenControllerFactory.sol:OpenControllerFactory']).then(() => {
        done();
      });
    },
  },
  plugins: [
    new options.plugins.JSONFilter(),
    new options.plugins.JSONExpander(),
  ],
});
