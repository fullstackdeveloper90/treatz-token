module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8546,
      network_id: "*" 
    },
     ropsten:  {
     network_id: 3,
     host: "localhost",
     port:  8545,
     gas:   2900000
    },
    mainnet: {
      gas: 4600000,
      gasPrice: 20000000000,
      network_id: "1",
    }
  }
};