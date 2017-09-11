const assert = require('chai').assert;
const { Eth, eth, defaultTxObject, environment, contracts } = require('../../../internals/mocha/config');

describe('OpenControllerFactory', () => {
  it('should have contract interfaces included', () => {
    assert.isOk(environment.OpenControllerFactory.address);
  });

  it('should deploy a OpenController contract and use some controller methods', async function () { // eslint-disable-line
  });
});
