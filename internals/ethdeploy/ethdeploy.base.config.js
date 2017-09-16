module.exports = environment => (options) => ({ // eslint-disable-line
  entry: [
    './src/contracts/lib/environments.json',
    './src/contracts',
  ],
  output: {
    path: './src/contracts/lib/',
    filename: 'environments.json',
    safe: true,
  },
  module: {
    environment,
    preLoaders: [
      { test: /(environments)\.(json)$/, loader: 'ethdeploy-environment-loader', build: true },
    ],
    loaders: [
      {
        test: /\.(sol)$/,
        exclude: /(test\.)/,
        loader: 'ethdeploy-solc-loader',
        base: 'src/contracts/',
        filterFilenames: true,
        filterWarnings: true,
        adjustBase: true,
      },
    ],
    deployment: (deploy, contracts, done) => {
      deploy(contracts.OpenControllerFactory)
      .then(() => {
        done();
      });
    },
  },
  plugins: [
    new options.plugins.IncludeContracts([
      'Controller',
      'IProposable',
      'OpenController',
      'OpenControllerFactory',
      'IRules',
      'MiniMeToken',
      'IProxy',
      'IOwned',
      'IPrivateServiceRegistry',
      'IToken',
      'Proxy',
      'IMembershipRegistry',
      'HelperMethods',
    ]),
    new options.plugins.JSONFilter(),
    new options.plugins.JSONExpander(),
  ],
});
