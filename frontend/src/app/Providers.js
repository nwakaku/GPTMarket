'use client';

import * as React from 'react';
import {
  RainbowKitProvider,
  getDefaultWallets,
  connectorsForWallets,
} from '@rainbow-me/rainbowkit';
import {
  argentWallet,
  trustWallet,
  ledgerWallet,
} from '@rainbow-me/rainbowkit/wallets';
import { configureChains, createConfig, WagmiConfig } from 'wagmi';
import {
  mainnet,
  polygon,
  arbitrum,
  goerli,
  avalancheFuji,
  polygonZkEvmTestnet,
  sepolia,
} from 'wagmi/chains';
import { publicProvider } from 'wagmi/providers/public';
import { ContractProvider } from './ContractContext';
import { xrplEvm, Pegasus } from './chain';


const { chains, publicClient, webSocketPublicClient } = configureChains(
  [
    mainnet,
    polygon,
    xrplEvm,
    arbitrum,
    avalancheFuji,
    polygonZkEvmTestnet,
    Pegasus,
    sepolia,
    ...(process.env.NEXT_PUBLIC_ENABLE_TESTNETS === 'true' ? [goerli] : []),
  ],
  [publicProvider()]
);

const projectId = "65c8eac925c69ff2ffbf2b1309a29786";

const { wallets } = getDefaultWallets({
  appName: 'GPTStore',
  projectId,
  chains,
});

const demoAppInfo = {
  appName: 'GPTStore',
};

const connectors = connectorsForWallets([
  ...wallets,
  {
    groupName: 'Other',
    wallets: [
      argentWallet({ projectId, chains }),
      trustWallet({ projectId, chains }),
      ledgerWallet({ projectId, chains }),
    ],
  },
]);

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
  webSocketPublicClient,
});

export function Providers({ children }) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);
  return (
    <ContractProvider>
      <WagmiConfig config={wagmiConfig}>
        <RainbowKitProvider chains={chains} appInfo={demoAppInfo}>
          {mounted && children}
        </RainbowKitProvider>
      </WagmiConfig>
    </ContractProvider>
  );
}
