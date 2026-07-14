import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { OWNER, PRE_MINT_CONFIG, WHITELIST_CONFIG } from "../utils/constants.js";

export default buildModule("LouvrModule", function (m) {
    const LouvrTreasury = m.contract("LouvrTreasury", [OWNER])

    const LouvrWhitelist = m.contract("LouvrWhitelist", [
        WHITELIST_CONFIG,
        OWNER
    ])

    const Louvr = m.contract("Louvr", [
        "Louvr", "Louvr3",
        LouvrTreasury, LouvrWhitelist,
        OWNER, PRE_MINT_CONFIG
    ])

    return { LouvrTreasury, LouvrWhitelist, Louvr }
})