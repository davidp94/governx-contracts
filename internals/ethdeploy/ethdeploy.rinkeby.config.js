const ethdeployBase = require('./ethdeploy.base.config.js');
const SignerProvider = require('ethjs-provider-signer'); // eslint-disable-line
const sign = require('ethjs-signer').sign; // eslint-disable-line
const account = require('../../../../account2.json');

module.exports = ethdeployBase({
  name: 'rinkeby',
  provider: new SignerProvider('https://rinkeby.infura.io', {
    signTransaction: (rawTx, cb) => {
      cb(null, sign(rawTx, account.privateKey));
    },
    accounts: cb => cb(null, [account.address]),
  }),
  defaultTxObject: {
    from: 0,
    gas: 4000000,
  },
});
