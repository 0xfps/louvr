import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { Louvr } from "./init.js"
dotenv.config()

async function count() {
    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        tx = await Louvr.totalMinted()
        console.log({ tx })
    })
}

count()