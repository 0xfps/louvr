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
  chainDescriptors: {
    46630: {
      name: "robinhoodTestnet",
      blockExplorers: {
        blockscout: {
          name: "Robinhood Chain Testnet Explorer",
          url: "https://explorer.testnet.chain.robinhood.com",
          apiUrl: "https://explorer.testnet.chain.robinhood.com/api"
        }
      }
    },
    4663: {
      name: "robinhoodMainnet",
      blockExplorers: {
        blockscout: {
          name: "Robinhood Chain Explorer",
          url: "https://robinhoodchain.blockscout.com",
          apiUrl: "https://robinhoodchain.blockscout.com/api"
        }
      },
    }
  },
  plugins: [hardhatFoundry, hardhatIgnitionViemPlugin, hardhatVerify]
});
