import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { ethers } from "ethers"
import artifact from "../artifacts/contracts/LouvrWhitelist.sol/LouvrWhitelist.json"
dotenv.config()

enum Tiers {
    PUBLIC,
    FIRST_COME_FIRST_SERVE,
    GUARANTEED,
    NONE
}

async function setTier() {
    const url = `https://robinhood-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY!}`
    const whitelistAddress = "0x4734C638b9443507947872e369cb6D8D5030A1eb"

    let wallet = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY!)

    const provider = new ethers.JsonRpcProvider(url)
    wallet = wallet.connect(provider)
    const LouvrWhitelist = new ethers.Contract(whitelistAddress, artifact.abi, wallet)

    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        tx = await LouvrWhitelist.setNewTier(Tiers.NONE)
        // tx = await LouvrWhitelist.setNewTier(Tiers.GUARANTEED)
        // tx = await LouvrWhitelist.setNewTier(Tiers.FIRST_COME_FIRST_SERVE)
        // tx = await LouvrWhitelist.setNewTier(Tiers.PUBLIC)
        await tx.wait()
        console.log({ tx })
    })
}

setTier()