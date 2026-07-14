import { defineConfig } from "hardhat/config";
import hardhatFoundry from "@nomicfoundation/hardhat-foundry";
import hardhatIgnitionViemPlugin from "@nomicfoundation/hardhat-ignition-viem";
import hardhatVerify from "@nomicfoundation/hardhat-verify";
import dotenv from "dotenv"

dotenv.config()

export default defineConfig({
  solidity: {
    version: "0.8.28",
  },
  networks: {
    robinhoodTestnet: {
      type: "http",
      url: `https://robinhood-testnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY!}`,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!]
    },
    robinhoodMainnet: {
      type: "http",
      url: `https://robinhood-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY!}`,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!]
    },
  },
  verify: {
    etherscan: {
      apiKey: process.env.ETHERSCAN_API_KEY,
    },
  },
  plugins: [hardhatFoundry, hardhatIgnitionViemPlugin, hardhatVerify]
});
