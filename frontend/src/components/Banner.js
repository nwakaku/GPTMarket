// Banner.js
import React from "react";
import Image from "next/image";


const Banner = () => {
  return (
    <section class="min-h-screen bg-white flex items-center justify-center">
      {" "}
      <div class="border-b border-gray-900 grid max-w-screen-xl px-2 mx-auto lg:gap-8 xl:gap-0 lg:pb-12 lg:grid-cols-10 mb-3">
        <div class="mr-auto place-self-center lg:col-span-5">
          <h1 class="max-w-2xl mb-4 text-6xl font-extrabold leading-tight md:text-4xl xl:text-6xl text-black dark:text-black">
            Unleash the Future:
            <br />
            AI-Powered NFT Marketplace.🚀
          </h1>

          <p class="max-w-xl mb-8 font-light text-gray-500 lg:mb-10 md:text-lg lg:text-xl dark:text-gray-800">
            Dive into the frontier of technology with our AI GPT Marketplace,
            pioneering the decentralized web. Explore the boundless
            possibilities of GPT technology.
          </p>
          <a
            href="/services"
            class="inline-flex items-center justify-center px-5 py-3 mr-3 text-base font-medium text-center text-white rounded-lg bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 dark:focus:ring-green-900">
            Get started
            <svg
              class="w-5 h-5 ml-2 -mr-1"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg">
              <path
                fill-rule="evenodd"
                d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
                clip-rule="evenodd"></path>
            </svg>
          </a>
          <a
            href="https://gptstore.gitbook.io/trivemind.doc/"
            class="ml-2 inline-flex items-center justify-center px-5 py-3 text-base font-medium text-center text-gray-900 border border-gray-300 rounded-lg hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 dark:text-white dark:border-gray-700 dark:hover:bg-gray-700 dark:focus:ring-gray-800">
            Docs
          </a>
        </div>
        <div class="hidden lg:mt-0 lg:col-span-5 lg:flex">
          <img
            src={
              "https://bafybeieyuio73zg2c53biwhfw7mtor2p2reabljwswvyxoyw62ug5y7tn4.ipfs.nftstorage.link/"
            }
            alt="mockup"
            className="w-108 h-120 rounded-3xl"
          />
        </div>
      </div>
    </section>
  );
};

export default Banner;
