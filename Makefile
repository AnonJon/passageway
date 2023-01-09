-include .env

test-contracts: 
	npx hardhat test --show-stack-traces

deploy-base:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/deploy-base.ts

deploy-template:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/tokens/L2StandardERC721.ts

deploy-bridge-l1:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/ERC721/deploy-bridge-l1.ts

deploy-bridge-l2:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/ERC721/deploy-bridge-l2.ts

deploy-controller-l1:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/deploy-controller.ts

deploy-controller-l2:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/deploy-controller.ts

message-l1:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/message-L1.ts

message-l2:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/message-L2.ts

initialize:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/ERC721/initialize.ts

deposit:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/ERC721/deposit.ts

withdraw:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/ERC721/withdraw.ts

test-nft:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/tokens/nft.ts
