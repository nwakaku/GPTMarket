import './globals.css'
import { Nunito } from 'next/font/google'
import '@rainbow-me/rainbowkit/styles.css';
import { Providers } from './Providers'

const inter = Nunito({ subsets: ["vietnamese"] });

export const metadata = {
  title: 'GPT Store ',
  description: 'Built with love at Light Hackathon 2024',
}

function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}

export default RootLayout;