# run python and...
from web3 import Web3
# connect to hardhat
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))
# are we really connected?
w3.is_connected()
# check available accounts
w3.eth.accounts
w3.eth.get_balance(w3.eth.accounts[0])
# get gas price
w3.eth.gas_price
# how many wei is 2 ether?
w3.to_wei('2', 'ether')
# create a new contract
bytecode = '0x' + '6080...'
abi = '[{"inputs":[],..."type":"receive"}]'
FaucetContract = w3.eth.contract(abi=abi, bytecode=bytecode)
# estimate gas for deploying contract
FaucetContract.constructor().estimate_gas()
# deploy contract and get transaction receipt and contract address
tx_hash = FaucetContract.constructor().transact({'from': w3.eth.accounts[0]})
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
contract_address = tx_receipt.contractAddress
# send some ether to the contract
tx_hash = w3.eth.send_transaction({"from": w3.eth.accounts[0], "to":
contract_address, "value": '200000000000000000'})




#
# in another python session...
#
# from web3 import Web3
# w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))
# # fill in contract address and ABI details
# contract_address = '...'
# abi = '...'
# # get the contract from the blockchain
# FaucetContract = w3.eth.contract(address=contract_address, abi=abi)
# # call the getBalance method
# FaucetContract.functions.getBalance().call()
# # call the withdraw method
# amount_to_withdraw = w3.to_wei('0.01', 'ether')
# tx_hash = FaucetContract.functions.withdraw(10000).transact({"from":
# w3.eth.accounts[2]})
# tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
# # check contract balance once more
# FaucetContract.functions.getBalance().call()