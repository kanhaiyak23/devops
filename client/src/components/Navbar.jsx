function Navbar() {
    return (
        <nav className="navbar" data-testid="navbar">
            <div className="navbar-container">
                <a href="#" className="navbar-logo">
                    <span className="logo-icon">🛒</span>
                    <span className="logo-text">ShopSmart</span>
                </a>
                <ul className="navbar-links">
                    <li><a href="#home" className="nav-link">Home</a></li>
                    <li><a href="#products" className="nav-link">Products</a></li>
                </ul>
            </div>
        </nav>
    );
}

export default Navbar;
