import dotenv from "dotenv"
import { ethers } from "ethers"
import artifact from "../artifacts/contracts/LouvrWhitelist.sol/LouvrWhitelist.json"
import louvrArtifact from "../artifacts/contracts/Louvr.sol/Louvr.json"
import louvrTreasuryArtifact from "../artifacts/contracts/LouvrTreasury.sol/LouvrTreasury.json"

dotenv.config()

const url = `https://robinhood-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY!}`

const treasury = "0xD3BFBa3751ce664Cda1f7051E3a1629Ec918353d"
const whitelistAddress = "0x4734C638b9443507947872e369cb6D8D5030A1eb"
const louvr = "0xE93b4cC4E67CCC845f5455d71c748807b4cC8f09"

let wallet = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY!)

const provider = new ethers.JsonRpcProvider(url)
wallet = wallet.connect(provider)

export const LouvrTreasury = new ethers.Contract(treasury, louvrTreasuryArtifact.abi, wallet)
export const LouvrWhitelist = new ethers.Contract(whitelistAddress, artifact.abi, wallet)
export const Louvr = new ethers.Contract(louvr, louvrArtifact.abi, wallet)