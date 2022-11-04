const {BigNumber} = require('ethers')
const hre = require('hardhat')

const data = require('../airdrop.json')
const contractABI = require('../abi/NewtroDrops.json')

const airdrop = async (id) => {
	const recipients = data.recipients[id]
	const contractAddress = data.contract_address

	const collectionURI = require('../metadata/uris').drops[id]
	const uri = 'https://ipfs.io/ipfs/' + collectionURI
	console.log('uri:', uri)

	let deployer, addrs
	;[deployer, ...addrs] = await ethers.getSigners()

	const newtro = await new ethers.Contract(
		contractAddress,
		contractABI,
		deployer
	)

	const tx = await newtro.airdrop(recipients, uri)
	await tx.wait()

	console.log(tx)
}

airdrop('1')
