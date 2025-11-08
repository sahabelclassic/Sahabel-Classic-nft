const hre = require("hardhat");
const fs = require("fs");

async function main() {
  await hre.run("compile");
  const ShopPass = await hre.ethers.getContractFactory("ShopPass");
  const contract = await ShopPass.deploy();
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log("Deployed ShopPass at:", address);

  const art = JSON.parse(
    fs.readFileSync("./artifacts/contracts/ShopPass.sol/ShopPass.json","utf8")
  );
  const out = {
    address,
    abi: art.abi,
    network: hre.network.name,
    chainId: hre.network.config.chainId,
    deployedAt: new Date().toISOString(),
  };
  fs.writeFileSync("./deployment-output.json", JSON.stringify(out,null,2));
  console.log("Wrote deployment-output.json");
}

main().catch((e)=>{ console.error(e); process.exit(1); });
