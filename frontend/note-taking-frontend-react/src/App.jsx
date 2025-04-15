import { useEffect, useState } from "react";

function App() {
  const [notes, setNotes] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    fetch("https://notes.carichung.com/notes") 
      .then((res) => res.json())
      .then((data) => setNotes(data))
      .catch((err) => {
        console.error("Fetch error:", err);
        setError("⚠️ Failed to load notes.");
      });
  }, []);

  return (
    <div style={{ padding: "2rem", fontFamily: "Arial" }}>
      <h1>📝 My Notes</h1>
      {error && <p>{error}</p>}
      <ul>
        {notes.map((note, idx) => (
          <li key={idx}>{note}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
