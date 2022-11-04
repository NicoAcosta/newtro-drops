require('@nomicfoundation/hardhat-toolbox')
require('@nomiclabs/hardhat-etherscan')
require('hardhat-abi-exporter')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: '0.8.17',
	networks: {
		mumbai: {
			url: process.env.MUMBAI_RPC,
			accounts: [process.env.MUMBAI_PK]
		}
	},
	etherscan: {
		apiKey: process.env.POLYGONSCAN_API_KEY
	},
	abiExporter: {
		path: './abi',
		runOnCompile: true,
		clear: true,
		flat: true,
		only: ['NewtroDrops', 'INewtroDrops'],
		spacing: 2,
		pretty: true
	}
}
