enum Tiers {
    PUBLIC,
    GUARANTEED,
    FIRST_COME_FIRST_SERVE,
    NONE
}

export type WhitelistConfig = {
    user: string,
    tier: Tiers
}

export type PreMintConfig = {
    teamMember: string,
    id: number
}

export const OWNER = "0x69F86467Abf580896faB8eFC73b2BC74aF18b8D4"
export const WHITELIST_CONFIG: WhitelistConfig[] = [{
    user: "0x5e078E6b545cF88aBD5BB58d27488eF8BE0D2593",
    tier: Tiers.GUARANTEED
}, {
    user: "0x476560be8FE235be47C23ef5dED61E2769b44f1F",
    tier: Tiers.FIRST_COME_FIRST_SERVE
}, {
    user: "0x7E395b6eeC0471737f5FCe27cF0e2A9851374E09",
    tier: Tiers.PUBLIC
}]
export const PRE_MINT_CONFIG: PreMintConfig[] = [{
    teamMember: "0x7E395b6eeC0471737f5FCe27cF0e2A9851374E09",
    id: 777
}]