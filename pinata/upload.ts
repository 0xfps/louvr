import { PinataSDK } from "pinata";
import fs from "node:fs"
import path from "path"
import dotenv from "dotenv"

dotenv.config()

const __dirname = import.meta.dirname

const { PINATA_GATEWAY, PINATA_API_JWT_SECRET } = process.env

const pinata = new PinataSDK({
    pinataJwt: PINATA_API_JWT_SECRET,
    pinataGateway: PINATA_GATEWAY
})

const images = "../assets/legendz/images"
const metadata = "../assets/legendz/metadata"

const imageDir = path.join(__dirname, images)
const metadataDir = path.join(__dirname, metadata)

const imageFiles = fs.readdirSync(imageDir)
const metadataFiles = fs.readdirSync(metadataDir)

imageFiles.sort((a: any, b: any) => a.localeCompare(b, undefined, { numeric: true }))
metadataFiles.sort((a: any, b: any) => a.localeCompare(b, undefined, { numeric: true }))

console.log("==================================================")
console.log("Counting Images.")
console.log(`${imageFiles.length} images found.`)
console.log("==================================================")
console.log("\n")

console.log("==================================================")
console.log("Counting Metadata.")
console.log(`${metadataFiles.length} metadata found.`)
console.log("==================================================")
console.log("\n")

let fileArrayStartFile = 1
const fileArraySize = 10
let fileArrayEndFile = (fileArraySize - 1) + fileArrayStartFile

async function handleImageFiles() {
    console.log("==================================================")
    console.log("Commencing upload of image files in folder.")
    console.log("==================================================")
    console.log("\n")

    while (fileArrayEndFile <= 2030) {
        const index = fileArrayStartFile - 1
        const files = imageFiles.slice(index, index + fileArraySize)
        await uploadImageFiles(files)
        fileArrayStartFile += fileArraySize
        fileArrayEndFile += fileArraySize
    }
}

async function uploadImageFiles(imageFiles: string[]) {
    console.log("==================================================")
    console.log("Commencing upload of image files in folder.")
    console.log(`Image ${imageFiles[0]} ======= Image ${imageFiles[imageFiles.length - 1]}.`)
    console.log("==================================================")
    console.log("\n")

    const pinataImageFolder = imageFiles.map(function (imageFile) {
        console.log(`Preparing file ${imageFile}.`)
        const imageContent = fs.readFileSync(path.join(__dirname, images, imageFile))
        return new File([imageContent], imageFile, { type: "image/png" })
    })

    console.log(`Uploading files.`)
    const { cid } = await pinata.upload.public.fileArray(pinataImageFolder)
    console.log(`Files uploaded, CID ${cid}.`)

    console.log("==================================================")
    console.log("Commencing metadata update.")
    console.log("==================================================")
    console.log("\n")

    imageFiles.forEach(function (imageToMetadataFile) {
        const metadataFileNumber = imageToMetadataFile.split(".")[0]
        const metadataFileName = `${metadataFileNumber}.json`

        const content = JSON.parse(
            fs.readFileSync(
                path.join(__dirname, metadata, metadataFileName)
            ) as any
        )


        const newContent = {
            ...content,
            httpsImage: `https://ipfs.io/ipfs/${cid}/${metadataFileNumber}.png`,
            image: `ipfs://${cid}/${metadataFileNumber}.png`
        }

        fs.writeFileSync(
            path.join(__dirname, metadata, metadataFileName),
            JSON.stringify(newContent, undefined, 2)
        )

        console.log(`Updated metadata for ${imageToMetadataFile} at ${metadataFileName}.`)
    })
}

async function uploadMetadataFiles() {
    console.log("==================================================")
    console.log("Commencing upload of metadata files in folder.")
    console.log("==================================================")
    console.log("\n")

    const pinataMetadataFolder = metadataFiles.map(function (metadataFile) {
        console.log(`Preparing file ${metadataFile}.`)
        const metadataContent = fs.readFileSync(path.join(__dirname, metadata, metadataFile))
        return new File([metadataContent], metadataFile, { type: "application/json" })
    })

    console.log(`Uploading files.`)
    const { cid } = await pinata.upload.public.fileArray(pinataMetadataFolder)
    console.log(`Files uploaded, CID ${cid}.`)

    fs.writeFileSync(path.join(__dirname, "ipfs.json"), JSON.stringify({
        cid,
        uri: `https://ipfs.io/ipfs/${cid}/`,
        baseUri: `ipfs://${cid}/`,
    }, undefined, 2))

    console.log(`ipfs.json written.`)
}

handleImageFiles().then(function () {
    console.log("Image upload finished.")

    uploadMetadataFiles().then(function () {
        console.log("Metadata upload finished.")
    }).catch(function (e) { throw new Error(e) })
}).catch(function (e) { throw new Error(e) })