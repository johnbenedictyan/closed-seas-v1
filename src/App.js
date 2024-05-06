import { Route, Routes } from "react-router-dom";
import "./App.css";
import Marketplace from "./components/Marketplace";
import NFTPage from "./components/NFTpage";
import Profile from "./components/Profile";
import SellNFT from "./components/SellNFT";

function App() {
  return (
    <div className="container">
      <Routes>
        <Route path="/" element={<Marketplace />} />
        <Route path="/nftPage/:tokenId" element={<NFTPage />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/sellNFT" element={<SellNFT />} />
      </Routes>
    </div>
  );
}

export default App;
