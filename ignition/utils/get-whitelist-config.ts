import { ethers } from "ethers";
import { FCFS } from "../../whitelists/fcfs.js";
import { GTD } from "../../whitelists/gtd.js";

export function getWhiteListConfig(): { user: string, tier: number }[] {
    const fcfs = FCFS
    const gtd = GTD

    const WhitelistConfig: { user: string, tier: number }[] = []

    for (const wallet of fcfs) {
        try {
            WhitelistConfig.push({
                user: ethers.getAddress(wallet),
                tier: 1
            })
        } catch { }
    }

    for (const wallet of gtd) {
        try {
            WhitelistConfig.push({
                user: ethers.getAddress(wallet),
                tier: 2
            })
        } catch { }
    }

    return WhitelistConfig
}