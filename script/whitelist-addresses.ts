import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { ethers, isAddress } from "ethers"
import artifact from "../artifacts/contracts/LouvrWhitelist.sol/LouvrWhitelist.json"
import { getWhiteListConfig } from "../ignition/utils/get-whitelist-config.js"
dotenv.config()

async function whitelist() {
    const url = `https://robinhood-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY!}`
    const whitelistAddress = "0x4734C638b9443507947872e369cb6D8D5030A1eb"

    let wallet = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY!)

    const provider = new ethers.JsonRpcProvider(url)
    wallet = wallet.connect(provider)
    const LouvrWhitelist = new ethers.Contract(whitelistAddress, artifact.abi, wallet)

    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        tx = await LouvrWhitelist.whitelist(getWhiteListConfig())
        await tx.wait()
        console.log({ tx })
    })
}

whitelist()