import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { ethers, isAddress } from "ethers"
import artifact from "../artifacts/contracts/LouvrWhitelist.sol/LouvrWhitelist.json"
import artifact2 from "../artifacts/contracts/Louvr.sol/Louvr.json"
dotenv.config()

async function whitelist() {
    const url = "https://rpc.testnet.chain.robinhood.com/rpc"
    const whitelistAddress = "0x7ba0e6a55891261Ea7C2f6E75a68b0756992Ffab"
    const louvrAddress = "0xD3F0a29d7d6F16Ea3b9dA355175C8db302C2C112"
    // const abi = require("../artifacts/contracts/LouvrWhitelist.sol/LouvrWhitelist.json")

    let wallet = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY!)

    const provider = new ethers.JsonRpcProvider(url)
    wallet = wallet.connect(provider)
    const LouvrWhitelist = new ethers.Contract(whitelistAddress, artifact.abi, wallet)
    const Louvr = new ethers.Contract(louvrAddress, artifact2.abi, wallet)

    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        tx = await LouvrWhitelist.whitelist([{
            user: "0xb69babfce22fa2eeaa27a913b2e88ae31b3ecff3",
            tier: 1
        }, {
            user: "0x7fd1a4d30dcf5e6f4e8f2d2c60d926e73fb4a2f6",
            tier: 1
        }, {
            user: "0xd918ac37e52709f7ff24f1fe42ef8d874244a542",
            tier: 2
        }, {
            user: "0xc5052f5fe67c91b7ae67e6a334eb33d0ee5922dc",
            tier: 2
        }])
    })
}

whitelist()