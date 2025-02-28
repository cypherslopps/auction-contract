#Auction Contract Test Process**

1. An auctioneer creates an auction in the smart contract. He decides the auction duration. Also, the auctioneer gives allowance to the Auction contract for a particular NFT, which will be the prize of the auction. Once the auction is created, the Auction contract takes the NFT from the auctioneer.

2. Any user who is willing to bid for an NFT has a positive USDC token balance. This user gives USDC allowance to the Auction smart contract.

3. The bidder places a bid by choosing an auction ID and the amount of USDC he is willing to offer. If his offer is higher than the current highest bid, then the bidder's offer is accepted

4. Once the time frame for an auction ends, anyone can terminate the auction, triggering the transfer of NFT to the highest bidder.

5. Bidders (other than the winner) will be albe to withdraw their USDC invested in the auction process.

> [!NOTE]
> This contract interacts with 3 contracts: USDC Token (ERC20 Contract), Auction and NFT Contracts

> [!NOTE]
> Hardhart Ignition is like a deployment manager. It helps publish smart contracts in a very reliable and structured way. It can resolve dependencies between contracts and other deployment steps.

> [!NOTE]
> **Deployment Ignition Script**: It's a reusable script for publishing smart contracts.
> 
> ***Resources***: https://hardhat.org/ignition/docs/getting-started


```` cmd
	$ mkdir ignition
	$ mkdir ignition/modules
	$ mkdir ignition/modules/auctionDeployment.js
````

#auctionDeployment.js

```` javascript
	const { buildModule } = require("@nomicfoundation/hardhat-ignition");

	module.exports = buildModule("DeployAuction", m => {
		const owner = m.getAccount(0);
		
		const initialOwner = m.getParameter("initialOwner", owner);
		
		const usdcAddress = m.getParameter("usdcAddress", ethers.ZeroAddress);
		
		  
		// Auction Constructor
		const auction = m.contract("Auction", [initialOwner, usdcAddress]);
		
		return { auction };
	});
````

### **Deploying AuctionContract using parameter**

==amoyParams.json==

```` json
{
	"DeployAuction": {
		"usdcAddress": "0x41e94eb019c0762f9bfcf9fb1e58725bfb0e7582"
	}
}
````

This takes the usdcAddress parameter for the DeployAuction module from auctionDeployment.js to  this "0x41e94eb019c0762f9bfcf9fb1e58725bfb0e7582".

##### **Executing a Deployment using parameters:**

```` cmd

npx hardhat ignition deploy ignition/modules/auctionDeployment.js --paramaters ignition/amoyParams.json
````


### **Deploying a Sample Contract to a Local Network using Hardhat Ignition**

```` cmd
	npm i @nomicfoundation/hardhat-ignition-ethers 
````

### **Creating your first module**

```` typescript
	
	import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

	export default buildModule("Apollo", m => {
		const apollo = m.contract("Rocket", ["Saturn V"]);
	
		m.call(apollo, "launch", []);

		return { apollo };
	});
````

> [!NOTE]
> Modules are created by calling the ==buildModule== function, which requires a module ID and a callback function. This is where the module definition actually happens.
> 
> The m parameter passed into the callback is an instance of a ModuleBuilder, which is an object with methods to define and configure your smart contract instances

These ModulBuilder methods create a Future object, which represents the result of an execution step that Hardhat Ignition needs to run to deploy a contract instance or interact with an existing one. E.G. (contract and call methods). "Contract method" deploys the contract instance, specifying "**Saturn V**" as the only constructor parameter. "Call method" executes the contract methods "**launch**"

==Deploying Contract==

The below command runs the local node

``` cmd
	npx hardhat node
```

Executing Hardhat Ignition

```` cmd
	
	npx hardhat ignition deploy ignition/modules/Apollo.ts --network localhost
````
