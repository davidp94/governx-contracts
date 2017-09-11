## governx-contracts

<div>
  <!-- Dependency Status -->
  <a href="https://david-dm.org/governx/governx-contracts">
    <img src="https://david-dm.org/governx/governx-contracts.svg"
    alt="Dependency Status" />
  </a>

  <!-- devDependency Status -->
  <a href="https://david-dm.org/governx/governx-contracts#info=devDependencies">
    <img src="https://david-dm.org/governx/governx-contracts/dev-status.svg" alt="devDependency Status" />
  </a>

  <!-- NPM Version -->
  <a href="https://www.npmjs.org/package/ethjs-contract-boilerplate">
    <img src="http://img.shields.io/npm/v/ethjs-contract-boilerplate.svg"
    alt="NPM version" />
  </a>

  <!-- Javascript Style -->
  <a href="http://airbnb.io/javascript/">
    <img src="https://img.shields.io/badge/code%20style-airbnb-brightgreen.svg" alt="js-airbnb-style" />
  </a>
</div>

<br />

## Install

```
git clone https://github.com/governx/governx-contracts
cd governx-contracts
npm install
```

## Start

**This will start a testrpc instance which is used for JS testing.**

```
npm start
```

## Test

```
npm test
```

## Solidity or JS Testing

```
npm run test:contracts:solidity

npm run test:contracts:js
```

## Deployment

**Specify your account information in `internals/accounts/index.js`**

**Remember, do not publish/include your actual private keys in the repo.. require them from a source outside the repository**

```
npm run deploy:mainnet
npm run deploy:rinkeby

npm run deploy:testrpc
```

## Build

**This will build the outputted contract data (address/abi/interface etc).**

```
npm run build
```

## Internals

**Account Management (`internals/accounts`)**

All account data is included in the accounts directory. This is where you can define your account private keys/addresses/balances.

This boierplate is configured to use the same account accross all environments.

**Contract Deployment (`internals/ethdeploy`)**

All deployment configuration is included in this directory.

**Distribution (`internals/webpack`)**

All webpack related configuration is in this directory.

## Contributing

Please help better the ecosystem by submitting issues and pull requests to `governx-contracts`. We need all the help we can get to build the absolute best linting standards and utilities. We follow the AirBNB linting standard and the unix philosophy.

## Help out

There is always a lot of work to do, and will have many rules to maintain. So please help out in any way that you can:

- Create, enhance, and debug ethjs rules (see our guide to ["Working on rules"](./.github/CONTRIBUTING.md)).
- Improve documentation.
- Chime in on any open issue or pull request.
- Open new issues about your ideas for making `governx` better, and pull requests to show us how your idea works.
- Add new tests to *absolutely anything*.
- Create or contribute to ecosystem tools.
- Spread the word!

Please consult our [Code of Conduct](CODE_OF_CONDUCT.md) docs before helping out.

We communicate via [issues](https://github.com/governx/governx-contracts/issues) and [pull requests](https://github.com/governx/governx-contracts/pulls).

## Todo

The current TODO items are:

 - A clear command (clear all boilerplate contracts/tests)
 - Plop enabled contract instantiation

## Important documents

- [Changelog](CHANGELOG.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [License](https://raw.githubusercontent.com/governx/governx-contracts/master/LICENSE)

## Licence

This project is licensed under the MIT license, Copyright (c) 2016 Nick Dodson. For more information see LICENSE.md.

```
The MIT License

Copyright (c) 2016 Nick Dodson. nickdodson.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
