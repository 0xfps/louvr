import { defineConfig } from "hardhat/config";
import hardhatFoundry from "@nomicfoundation/hardhat-foundry";

export default defineConfig({
  solidity: {
    version: "0.8.28",
  },
  plugins: [hardhatFoundry]
});
