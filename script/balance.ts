import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { LouvrTreasury } from "./init.js"

dotenv.config()

async function balance() {
    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        tx = await LouvrTreasury.getBalance()
        const reduced = Number((Number(tx) / 1e18).toFixed(4))
        const usd = Number((reduced * 1931.73).toFixed(2))
        console.log({ tx, reduced, usd })
    })
}

balance()