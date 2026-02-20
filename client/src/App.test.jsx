import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import App from './App';
import Navbar from './components/Navbar';
import HeroSection from './components/HeroSection';
import ProductCard from './components/ProductCard';
import ProductsPage from './components/ProductsPage';

// ============================================
// Mock Data
// ============================================
const mockProducts = [
    {
        id: 1,
        name: 'Classic White Sneakers',
        price: 89.99,
        image: 'https://example.com/sneakers.jpg',
        category: 'Footwear',
        description: 'Premium leather sneakers'
    },
    {
        id: 2,
        name: 'Denim Jacket',
        price: 129.99,
        image: 'https://example.com/jacket.jpg',
        category: 'Outerwear',
        description: 'Vintage-wash denim jacket'
    },
    {
        id: 3,
        name: 'Running Performance Tee',
        price: 45.00,
        image: 'https://example.com/tee.jpg',
        category: 'Activewear',
        description: 'Moisture-wicking tee'
    }
];

// ============================================
// Unit Tests
// ============================================

describe('Unit Tests', () => {
    describe('Navbar', () => {
        it('renders the ShopSmart logo text', () => {
            render(<Navbar />);
            expect(screen.getByText('ShopSmart')).toBeInTheDocument();
        });

        it('renders Home and Products navigation links', () => {
            render(<Navbar />);
            expect(screen.getByText('Home')).toBeInTheDocument();
            expect(screen.getByText('Products')).toBeInTheDocument();
        });

        it('has correct test id', () => {
            render(<Navbar />);
            expect(screen.getByTestId('navbar')).toBeInTheDocument();
        });
    });

    describe('HeroSection', () => {
        it('renders the headline', () => {
            render(<HeroSection />);
            expect(screen.getByText('Elevate Your Style')).toBeInTheDocument();
        });

        it('renders the tagline', () => {
            render(<HeroSection />);
            expect(screen.getByText(/Discover curated collections/i)).toBeInTheDocument();
        });

        it('renders the CTA button', () => {
            render(<HeroSection />);
            expect(screen.getByText('Shop Now')).toBeInTheDocument();
        });

        it('has correct test id', () => {
            render(<HeroSection />);
            expect(screen.getByTestId('hero-section')).toBeInTheDocument();
        });
    });

    describe('ProductCard', () => {
        it('renders product name', () => {
            render(<ProductCard product={mockProducts[0]} />);
            expect(screen.getByText('Classic White Sneakers')).toBeInTheDocument();
        });

        it('renders product price', () => {
            render(<ProductCard product={mockProducts[0]} />);
            expect(screen.getByText('$89.99')).toBeInTheDocument();
        });

        it('renders product category badge', () => {
            render(<ProductCard product={mockProducts[0]} />);
            expect(screen.getByText('Footwear')).toBeInTheDocument();
        });

        it('renders product description', () => {
            render(<ProductCard product={mockProducts[0]} />);
            expect(screen.getByText('Premium leather sneakers')).toBeInTheDocument();
        });

        it('renders Add to Cart button', () => {
            render(<ProductCard product={mockProducts[0]} />);
            expect(screen.getByText('Add to Cart')).toBeInTheDocument();
        });

        it('renders product image with correct alt text', () => {
            render(<ProductCard product={mockProducts[0]} />);
            const img = screen.getByAltText('Classic White Sneakers');
            expect(img).toBeInTheDocument();
            expect(img).toHaveAttribute('src', 'https://example.com/sneakers.jpg');
        });
    });
});

// ============================================
// Integration Tests
// ============================================

// Mock the products data module so ProductsPage uses our mock data
vi.mock('./data/products', () => ({
    default: [
        {
            id: 1,
            name: 'Classic White Sneakers',
            price: 89.99,
            image: 'https://example.com/sneakers.jpg',
            category: 'Footwear',
            description: 'Premium leather sneakers'
        },
        {
            id: 2,
            name: 'Denim Jacket',
            price: 129.99,
            image: 'https://example.com/jacket.jpg',
            category: 'Outerwear',
            description: 'Vintage-wash denim jacket'
        },
        {
            id: 3,
            name: 'Running Performance Tee',
            price: 45.00,
            image: 'https://example.com/tee.jpg',
            category: 'Activewear',
            description: 'Moisture-wicking tee'
        }
    ]
}));

describe('Integration Tests', () => {
    describe('ProductsPage — renders products from mock data', () => {
        it('renders all products from mock data', () => {
            render(<ProductsPage />);
            expect(screen.getByText('Classic White Sneakers')).toBeInTheDocument();
            expect(screen.getByText('Denim Jacket')).toBeInTheDocument();
            expect(screen.getByText('Running Performance Tee')).toBeInTheDocument();
        });

        it('renders correct number of product cards', () => {
            render(<ProductsPage />);
            const cards = screen.getAllByTestId('product-card');
            expect(cards).toHaveLength(3);
        });

        it('renders search input', () => {
            render(<ProductsPage />);
            expect(screen.getByTestId('search-input')).toBeInTheDocument();
        });

        it('renders the section title', () => {
            render(<ProductsPage />);
            expect(screen.getByText('Our Products')).toBeInTheDocument();
        });
    });

    describe('ProductsPage — search filters products with mock data', () => {
        it('filters products by name when typing in search', () => {
            render(<ProductsPage />);
            const searchInput = screen.getByTestId('search-input');

            fireEvent.change(searchInput, { target: { value: 'Sneaker' } });

            expect(screen.getByText('Classic White Sneakers')).toBeInTheDocument();
            expect(screen.queryByText('Denim Jacket')).not.toBeInTheDocument();
            expect(screen.queryByText('Running Performance Tee')).not.toBeInTheDocument();
        });

        it('filters products by category', () => {
            render(<ProductsPage />);
            const searchInput = screen.getByTestId('search-input');

            fireEvent.change(searchInput, { target: { value: 'Outerwear' } });

            expect(screen.getByText('Denim Jacket')).toBeInTheDocument();
            expect(screen.queryByText('Classic White Sneakers')).not.toBeInTheDocument();
        });

        it('shows no results message for unmatched search', () => {
            render(<ProductsPage />);
            const searchInput = screen.getByTestId('search-input');

            fireEvent.change(searchInput, { target: { value: 'xyznonexistent' } });

            expect(screen.getByText(/No products found/i)).toBeInTheDocument();
        });

        it('search is case insensitive', () => {
            render(<ProductsPage />);
            const searchInput = screen.getByTestId('search-input');

            fireEvent.change(searchInput, { target: { value: 'denim' } });

            expect(screen.getByText('Denim Jacket')).toBeInTheDocument();
        });

        it('shows all products when search is cleared', () => {
            render(<ProductsPage />);
            const searchInput = screen.getByTestId('search-input');

            // Type something to filter
            fireEvent.change(searchInput, { target: { value: 'Sneaker' } });
            expect(screen.getAllByTestId('product-card')).toHaveLength(1);

            // Clear search
            fireEvent.change(searchInput, { target: { value: '' } });
            expect(screen.getAllByTestId('product-card')).toHaveLength(3);
        });
    });

    describe('App — full page integration with mock data', () => {
        it('renders Navbar, HeroSection, and ProductsPage together', () => {
            render(<App />);

            // Navbar present
            expect(screen.getByTestId('navbar')).toBeInTheDocument();

            // Hero section present
            expect(screen.getByTestId('hero-section')).toBeInTheDocument();
            expect(screen.getByText('Elevate Your Style')).toBeInTheDocument();

            // Products page present
            expect(screen.getByTestId('products-page')).toBeInTheDocument();
            expect(screen.getByText('Our Products')).toBeInTheDocument();
        });

        it('renders product cards from mock data in full app', () => {
            render(<App />);
            const cards = screen.getAllByTestId('product-card');
            expect(cards).toHaveLength(3);
        });
    });
});
