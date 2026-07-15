import path from "path"
import fs from "node:fs"
import { ethers } from "ethers"

const ids = [
    3, 6, 9, 43, 49, 55, 77, 154,
    163, 177, 188, 194, 201, 210, 225, 274,
    277, 320, 328, 338, 351, 352, 363,
    392, 404, 407, 423, 430, 433, 445, 451,
    468, 473, 484, 495
]

export function generateWallets(count: number) {
    const __dirname = import.meta.dirname
    const walletFilePath = path.join(__dirname, "wallets.json")
    const teamNFTsFilePath = path.join(__dirname, "team-nfts.json")
    const wallets = []
    const teamNfts = []
    
    for (let i = 0; i < count; i++) {
        const length = ids.length
        const randomNumber = Math.floor(Math.random() * 1000) % length

        const wallet = ethers.Wallet.createRandom()
        
        console.log(`Wallet {${i}}: ${wallet.address}.`)
        
        wallets.push(wallet)
        teamNfts.push({
            teamMember: wallet.address,
            id: ids[randomNumber]
        })
        
        ids.splice(randomNumber, 1)
    }

    fs.writeFileSync(walletFilePath, JSON.stringify(wallets))
    fs.writeFileSync(teamNFTsFilePath, JSON.stringify(teamNfts))
}

generateWallets(36)