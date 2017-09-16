const assert = require('chai').assert;
const { Eth, eth, defaultTxObject, environment, contracts } = require('../../../internals/mocha/config');

describe('HelperMethods', () => {
  it('should have contract interfaces included', () => {
    assert.isOk(contracts.SimpleStore);
  });

  it('should deploy a HelperMethods contract and use build method', async function () { // eslint-disable-line
    const HelperMethods = eth.contract(
      JSON.parse(contracts.HelperMethods.interface),
      contracts.HelperMethods.bytecode,
      defaultTxObject,
    );
    const helperTx = await HelperMethods.new();
    const helperReceipt = await eth.getTransactionSuccess(helperTx);
    const helper = HelperMethods.at(helperReceipt.contractAddress);
    const propData = (await helper.proposalData('set', helperReceipt.contractAddress, 0, '0x00'))[0];

    console.log(propData);
  });
});
