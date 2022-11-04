const {BigNumber} = require('ethers')
const hre = require('hardhat')

const collectionURI = require('../metadata/uris').collection
const uri = 'https://ipfs.io/ipfs/' + collectionURI

async function deploy() {
	let deployer, addrs
	;[deployer, ...addrs] = await ethers.getSigners()

	const Newtro = await hre.ethers.getContractFactory('NewtroDrops')
	const newtro = await Newtro.connect(deployer).deploy(uri)

	await newtro.deployed()

	console.log('Newtro Drops deployed to:', newtro.address)
	console.log('Deployed by:', deployer.address)
	console.log('Collection uri:', uri)
}

const tryToDeploy = async () => {
	// Repeat deploy() until gasPrice < block base fee
	deploy().catch((error) => {
		console.error(error)
		tryToDeploy()
	})
}

tryToDeploy()
