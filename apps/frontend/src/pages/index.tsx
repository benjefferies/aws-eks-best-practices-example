import { Inter } from "next/font/google";
import { useState } from "react";
import useSWR from "swr";
import fetch from "unfetch";

const inter = Inter({ subsets: ["latin"] });

const fetcher = (url: string) =>
  fetch(url).then((r: fetch.IsomorphicResponse) => r.json());

export default function Home() {
  const apiHost = process.env.NEXT_PUBLIC_API_HOST;
  const { isLoading, data, mutate } = useSWR(`${apiHost}/messages`, fetcher);
  const [newMessage, setNewMessage] = useState("");

  const addNewMessage = async () => {
    const res = await fetch(`${apiHost}/messages`, {
      method: "post",
      headers: {
        "content-type": "application/json",
        accept: "application/json",
      },
      body: JSON.stringify({
        message: newMessage,
      }),
    });

    return await res.json();
  };

  return (
    <main
      className={`flex min-h-screen flex-col items-center justify-between p-24 ${inter.className}`}
    >
      <div>
        <h1 className="text-4xl font-bold">Messages</h1>
      </div>
      <div className="flex flex-col w-full">
        {isLoading && <p>Loading...</p>}
        {data?.length > 0 &&
          data.map((message: string) => (
            <div className="flex items-center border-b-2 border-gray-200 py-4 px-4">
              <p key={message}>{message}</p>
            </div>
          ))}
      </div>
      <div className="flex items-center">
        <input
          className="mr-4 border-2 border-gray-200 p-2 rounded"
          type="text"
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
        />
        <button
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          onClick={async () => {
            await mutate(addNewMessage, {
              optimisticData: [...data, newMessage],
            });
            setNewMessage("");
          }}
        >
          Add message
        </button>
      </div>
    </main>
  );
}
