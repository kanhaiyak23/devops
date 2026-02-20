function HeroSection() {
    return (
        <section className="hero" id="home" data-testid="hero-section">
            <div className="hero-overlay"></div>
            <div className="hero-content">
                <h1 className="hero-headline">Elevate Your Style</h1>
                <p className="hero-tagline">
                    Discover curated collections that blend timeless elegance with modern trends.
                </p>
                <a href="#products" className="hero-cta">Shop Now</a>
            </div>
        </section>
    );
}

export default HeroSection;
