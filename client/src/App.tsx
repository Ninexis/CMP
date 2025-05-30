import React, { useState } from "react";

function App() {
  const [status, setStatus] = useState("");

  const deploy = async () => {
    setStatus("Deploying...");
    try {
      const res = await fetch("http://34.159.209.174:4000/run-terraform");
      const text = await res.text();
      setStatus(text);
    } catch (err) {
      setStatus("Error: " + (err as Error).message);
    }
  };

  return (
    <div style={{ padding: "2rem", fontFamily: "Arial" }}>
      <h1>Deploy OpenStack VM</h1>
      <button onClick={deploy}>Create VM</button>
      <pre>{status}</pre>
    </div>
  );
}

export default App;