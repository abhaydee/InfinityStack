'use client';

import { AppConfig, UserData, UserSession } from "@stacks/connect";
import { StacksNetwork, StacksMocknet } from "@stacks/network";
import { createContext, PropsWithChildren, useContext, useEffect, useState } from "react";
import { callReadOnlyFunction, makeContractCall, broadcastTransaction, AnchorMode, PostConditionMode, uintCV, principalCV } from "@stacks/transactions";

interface StacksContextValue {
  network: StacksNetwork
  address?: string
  userSession: UserSession,
  pauseContract: () => Promise<any>,
  unpauseContract: () => Promise<any>,
  emergencyWithdraw: (amount: number, recipient: string) => Promise<any>,
  isPaused: () => Promise<boolean>,
}

const AuthContext = createContext<StacksContextValue | undefined>(undefined);

const network = new StacksMocknet();

export default function StacksProvider({ children }: PropsWithChildren<{}>) {
  const [userData, setUserData] = useState<UserData | undefined>(undefined);

  const appConfig = new AppConfig(['store_write']);
  const userSession = new UserSession({ appConfig });
  const address: string | undefined = userData?.profile?.stxAddress?.testnet;

  useEffect(() => {
    if (userSession.isSignInPending()) {
      userSession.handlePendingSignIn().then((userData) => {
        setUserData(userData);
      });
    } else if (userSession.isUserSignedIn()) {
      setUserData(userSession.loadUserData());
    }
  }, []);

  const pauseContract = async () => {
    const txOptions = {
      contractAddress: 'ST1234567890abcdef1234567890abcdef12345678', // Replace with your contract address
      contractName: 'sbtc',
      functionName: 'pause-contract',
      functionArgs: [],
      senderKey: userSession.loadUserData().appPrivateKey,
      network,
      anchorMode: AnchorMode.Any,
      postConditionMode: PostConditionMode.Allow,
    };

    const transaction = await makeContractCall(txOptions);
    const result = await broadcastTransaction(transaction, network);
    return result;
  };

  const unpauseContract = async () => {
    const txOptions = {
      contractAddress: 'ST1234567890abcdef1234567890abcdef12345678', // Replace with your contract address
      contractName: 'sbtc',
      functionName: 'unpause-contract',
      functionArgs: [],
      senderKey: userSession.loadUserData().appPrivateKey,
      network,
      anchorMode: AnchorMode.Any,
      postConditionMode: PostConditionMode.Allow,
    };

    const transaction = await makeContractCall(txOptions);
    const result = await broadcastTransaction(transaction, network);
    return result;
  };

  const emergencyWithdraw = async (amount: number, recipient: string) => {
    const txOptions = {
      contractAddress: 'ST1234567890abcdef1234567890abcdef12345678', // Replace with your contract address
      contractName: 'sbtc',
      functionName: 'emergency-withdraw',
      functionArgs: [uintCV(amount), principalCV(recipient)],
      senderKey: userSession.loadUserData().appPrivateKey,
      network,
      anchorMode: AnchorMode.Any,
      postConditionMode: PostConditionMode.Allow,
    };

    const transaction = await makeContractCall(txOptions);
    const result = await broadcastTransaction(transaction, network);
    return result;
  };

  const isPaused = async (): Promise<boolean> => {
    const options = {
      contractAddress: 'ST1234567890abcdef1234567890abcdef12345678', // Replace with your contract address
      contractName: 'sbtc',
      functionName: 'is-paused',
      functionArgs: [],
      network,
      senderAddress: address!,
    };

    const result = await callReadOnlyFunction(options);
    return result.value.value;
  };

  const value: StacksContextValue = { network, address, userSession, pauseContract, unpauseContract, emergencyWithdraw, isPaused };
  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useStacks() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within a AuthProvider');
  }
  return context;
}