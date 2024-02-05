import { useState, useEffect } from "react";
import axios from "axios";

export const useFetchData = (URI) => {
  const [cardData, setCardData] = useState({
    name: "",
    image: "",
    match: "",
    description: "",
    priceHour: "",
    assistantID: "",
  });

  function extractHashFromIPFS(url) {
    const regex = /ipfs:\/\/([a-zA-Z0-9]+)/;
    const match = url.match(regex);

    if (match && match[1]) {
      return match[1];
    } else {
      // Handle invalid or missing hash
      return null;
    }
  }

  useEffect(() => {
    const fetchDataFromUrl = async (url) => {
      try {
        const cleanedUrl = extractHashFromIPFS(url);
        const src = `https://${cleanedUrl}.ipfs.dweb.link/metadata.json`;
        const response = await axios.get(src);

        if (!response.data) {
          throw new Error(`Failed to fetch data from ${url}`);
        }

        return response.data;
      } catch (error) {
        console.error(error.message);
        throw error; // Re-throw the error to be caught by the outer catch block
      }
    };

    const fetchData = async () => {
      try {
        const data = await fetchDataFromUrl(URI);

        if (data) {
          const ipfsUrl = data.image;
          const cleanedUrl = ipfsUrl.replace(/^ipfs:\/\//, "");

          setCardData({
            name: data.name,
            image: cleanedUrl,
            match: data.match,
            description: data.description,
            priceHour: data.priceHour,
            assistantID: data.assistantID,
          });
        }
      } catch (error) {
        // Handle the error, if needed
        console.error(error.message);
      }
    };

    fetchData();
  }, [URI]);

  return cardData;
};