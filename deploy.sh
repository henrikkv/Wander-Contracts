#!/bin/sh

forge create --rpc-url https://eth-sepolia.g.alchemy.com/v2/demo --chain 11155111 --private-key $(cat ~/.key) \
	--etherscan-api-key $(cat ~/.etherscan-api-key) \
	--verify \
	./src/Wander.sol:Wander
