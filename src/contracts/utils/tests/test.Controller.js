const assert = require('chai').assert;
const { Eth, eth, defaultTxObject, environment, contracts } = require('../../../../internals/mocha/config');

describe('Controller', () => {
  it('should have contract interfaces included', () => {
    assert.isOk(contracts.Controller);
    assert.isOk(contracts.OpenControllerFactory);
  });

  it('should deploy a Controller, propose and execute a trasaction', async function () { // eslint-disable-line
    const OpenControllerFactory = eth.contract(
      JSON.parse(contracts.OpenController.interface),
      contracts.OpenController.bytecode,
      defaultTxObject
    );

    const txHash = await OpenControllerFactory.new();
    const receipt = await eth.getTransactionSuccess(txHash);
    const openControllerFactory = OpenControllerFactory.at(receipt.contractAddress);

    const proxyTxHash = await openControllerFactory.createProxy();
    // const  = await eth.getTransactionSuccess(proxyTxHash);
  });
});
