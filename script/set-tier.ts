import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { LouvrWhitelist } from "./init.js"
dotenv.config()

enum Tiers {
    PUBLIC,
    FIRST_COME_FIRST_SERVE,
    GUARANTEED,
    NONE
}

async function setTier() {
    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        // tx = await LouvrWhitelist.setNewTier(Tiers.NONE)
        // tx = await LouvrWhitelist.setNewTier(Tiers.GUARANTEED)
        // tx = await LouvrWhitelist.setNewTier(Tiers.FIRST_COME_FIRST_SERVE)
        tx = await LouvrWhitelist.setNewTier(Tiers.PUBLIC)
        await tx.wait()
        console.log({ tx })

        tx = await LouvrWhitelist.currentTier()
        console.log({ tx })
    })
}

setTier()