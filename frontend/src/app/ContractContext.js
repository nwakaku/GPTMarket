import React, { createContext, useContext } from 'react';
import { getContract, getWalletClient } from '@wagmi/core';
import contractStuff from "../../contract/contract.json";

// Create a context with default values
const ContractContext = createContext({
  contractAbi: [],
  contractAddress: '',
  contract: null,
});

// Custom hook to use the context
export const useContract = () => useContext(ContractContext);

// Context provider component
export const ContractProvider = ({ children }) => {
  const contractAbi = contractStuff;
  //const contractAddress = "0xaaF545399bA242Ba7f51e0F3504e64b45048925E";
  // const contractAddress = "0x8dc90d8452708E93530E5a2cbB3d4A8B09754432";
  const contractAddress = "0xE203693C42E61Fd50142858A6f2642c3BFab158e";
  
  const walletClient = getWalletClient();

  // Create the contract instance
  const contract = getContract({
    address: contractAddress,
    abi: contractAbi,
    walletClient,
  });

  // Create the context value
  const contextValue = {
    contractAbi,
    contractAddress,
    contract,
  };

  return (
    <ContractContext.Provider value={contextValue}>
      {children}
    </ContractContext.Provider>
  );
};
