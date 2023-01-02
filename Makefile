-include .env

test-contracts: 
	npx hardhat test --show-stack-traces

run-ccm:
	npx hardhat run --network ${NETWORK_GOERLI} scripts/deploy.ts