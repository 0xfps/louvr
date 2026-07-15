import { Mutex } from "async-mutex"
import dotenv from "dotenv"
import { getWhiteListConfig } from "../ignition/utils/get-whitelist-config.js"
import { GTD, OLD_GTD } from "../whitelists/gtd.js"
import { FCFS, OLD_FCFS } from "../whitelists/fcfs.js"
import { LouvrWhitelist } from "./init.js"
dotenv.config()

async function whitelist() {
    let tx
    const mutex = new Mutex()
    await mutex.runExclusive(async function () {
        tx = await LouvrWhitelist.whitelist(getWhiteListConfig())
        await tx.wait()
        console.log({ tx })
    })

    console.log({
        gtd: OLD_GTD.length + GTD.length,
        fcfs: OLD_FCFS.length + FCFS.length,
        total: OLD_GTD.length + GTD.length + OLD_FCFS.length + FCFS.length
    })
}

whitelist()