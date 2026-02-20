import Navbar from "./components/Navbar";
import HeroSection from "./components/HeroSection";
import ProductsPage from "./components/ProductsPage";

function App() {
  return (
    <div className="app">
      <Navbar />
      <main>
        <HeroSection />
        <ProductsPage />
      </main>
    </div>
  );
}

export default App;
