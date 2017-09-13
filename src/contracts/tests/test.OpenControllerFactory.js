const assert = require('chai').assert;
const { Eth, eth, defaultTxObject, environment, contracts } = require('../../../internals/mocha/config');

describe('OpenControllerFactory', () => {
  it('should have contract interfaces included', () => {
    assert.isOk(environment.OpenControllerFactory.address);
  });

  it('should deploy a OpenController contract and use some controller methods', async function () { // eslint-disable-line
    const openControllerFactoryABI = JSON.parse(environment.OpenControllerFactory.interface);
    const OpenControllerFactory = eth.contract(openControllerFactoryABI, environment.OpenControllerFactory.bytecode, defaultTxObject);
    const factory = OpenControllerFactory.at(environment.OpenControllerFactory.address);
    const proxyTx = await factory.createProxy();
    const proxyReceipt = await eth.getTransactionSuccess(proxyTx);

    assert.eqaul(proxyReceipt.length, 1);

    const decoder = Eth.abi.logDecoder(openControllerFactoryABI);
    const events = decoder(proxyReceipt.logs);
    const proxyAddress = events[0]._service; // eslint-disable-line

    assert.isOk(proxyAddress);

    const Proxy = eth.contract(JSON.parse(contracts.Proxy.interface));
    const proxy = Proxy.at(proxyAddress);
    const controllerAddress = (await proxy.owner())[0];
    const OpenController = eth.contract(JSON.parse(contracts.Controller.interface));
    const controller = OpenController.at(controllerAddress);
    const numProposals = (await controller.numProposals())[0];

    assert.equal(numProposals.toString(10), '0');
  });
});
