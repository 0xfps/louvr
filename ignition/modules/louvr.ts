import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { OWNER } from "../utils/constants.js";
import { getWhiteListConfig } from "../utils/get-whitelist-config.js";
import { getPreMintConfig } from "../utils/get-premint-config.js";

export default buildModule("LouvrModule", function (m) {
    const LouvrTreasury = m.contract("LouvrTreasury", [OWNER])

    const LouvrWhitelist = m.contract("LouvrWhitelist", [
        [],
        OWNER
    ])

    const Louvr = m.contract("Louvr", [
        "Louvr", "Louvr3",
        LouvrTreasury, LouvrWhitelist,
        OWNER, getPreMintConfig()
    ])

    m.call(LouvrWhitelist, "whitelist", [getWhiteListConfig()])

    return { LouvrTreasury, LouvrWhitelist, Louvr }
})