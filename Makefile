-include .env

test-contracts: 
	npx hardhat test --show-stack-traces

deploy-base:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/deploy-base.ts

deploy-controller-l1:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/deploy-controller.ts

deploy-controller-l2:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/deploy-controller.ts

message-l1:
	npx hardhat run --network ${NETWORK_OPTIMISM_GOERLI} scripts/message-L1.ts

message-l2:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/message-L2.ts