const {BigNumber} = require('ethers')
const hre = require('hardhat')

const collectionMetadata =
	'https://ipfs.io/ipfs/bafkreiadclsfd7ph7qkbwgpbgf67ndibb22cdrshtnctn2xf2bz6q5rg6m'

async function deploy() {
	let deployer, addrs
	;[deployer, ...addrs] = await ethers.getSigners()

	const Newtro = await hre.ethers.getContractFactory('NewtroDrops')
	const newtro = await Newtro.connect(deployer).deploy(collectionMetadata)

	await newtro.deployed()

	console.log('Newtro Drops deployed to:', newtro.address)
	console.log('Deployed by:', deployer.address)
}

// const tryToDeploy = async () => {
// 	// Repeat deploy() until gasPrice < block base fee
// 	deploy().catch((error) => {
// 		console.error(error)
// 		tryToDeploy()
// 	})
// }

// tryToDeploy()

deploy()
