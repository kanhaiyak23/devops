import { test, expect } from '@playwright/test';

test.describe('ShopSmart E2E — Homepage', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
    });

    test('page loads with correct title', async ({ page }) => {
        await expect(page).toHaveTitle('ShopSmart');
    });

    test('navbar is visible with logo and nav links', async ({ page }) => {
        const navbar = page.locator('[data-testid="navbar"]');
        await expect(navbar).toBeVisible();
        await expect(navbar.locator('.logo-text')).toHaveText('ShopSmart');
        await expect(navbar.getByText('Home')).toBeVisible();
        await expect(navbar.getByText('Products')).toBeVisible();
    });

    test('hero section renders headline and CTA', async ({ page }) => {
        const hero = page.locator('[data-testid="hero-section"]');
        await expect(hero).toBeVisible();
        await expect(hero.locator('.hero-headline')).toHaveText('Elevate Your Style');
        await expect(hero.getByText('Shop Now')).toBeVisible();
    });

    test('products section renders with product cards', async ({ page }) => {
        const productsPage = page.locator('[data-testid="products-page"]');
        await expect(productsPage).toBeVisible();
        await expect(productsPage.locator('.products-title')).toHaveText('Our Products');

        const cards = productsPage.locator('[data-testid="product-card"]');
        await expect(cards).toHaveCount(8);
    });

    test('each product card shows name, price, and category', async ({ page }) => {
        const firstCard = page.locator('[data-testid="product-card"]').first();
        await expect(firstCard.locator('.product-name')).toBeVisible();
        await expect(firstCard.locator('.product-price')).toBeVisible();
        await expect(firstCard.locator('.product-category')).toBeVisible();
        await expect(firstCard.locator('.add-to-cart-btn')).toBeVisible();
    });
});

test.describe('ShopSmart E2E — Search', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/');
    });

    test('search input is visible and functional', async ({ page }) => {
        const searchInput = page.locator('[data-testid="search-input"]');
        await expect(searchInput).toBeVisible();
        await expect(searchInput).toHaveAttribute('placeholder', 'Search products...');
    });

    test('typing in search filters products by name', async ({ page }) => {
        const searchInput = page.locator('[data-testid="search-input"]');
        await searchInput.fill('Sneaker');

        const cards = page.locator('[data-testid="product-card"]');
        await expect(cards).toHaveCount(2); // Classic White Sneakers + Canvas High-Top Sneakers

        // Verify all visible cards contain "Sneaker" in name
        const names = cards.locator('.product-name');
        const count = await names.count();
        for (let i = 0; i < count; i++) {
            const text = await names.nth(i).textContent();
            expect(text.toLowerCase()).toContain('sneaker');
        }
    });

    test('search filters products by category', async ({ page }) => {
        const searchInput = page.locator('[data-testid="search-input"]');
        await searchInput.fill('Outerwear');

        const cards = page.locator('[data-testid="product-card"]');
        await expect(cards).toHaveCount(2); // Denim Jacket + Oversized Hoodie
    });

    test('search is case insensitive', async ({ page }) => {
        const searchInput = page.locator('[data-testid="search-input"]');
        await searchInput.fill('denim');

        const cards = page.locator('[data-testid="product-card"]');
        await expect(cards).toHaveCount(1);
        await expect(cards.first().locator('.product-name')).toHaveText('Denim Jacket');
    });

    test('non-matching search shows no results message', async ({ page }) => {
        const searchInput = page.locator('[data-testid="search-input"]');
        await searchInput.fill('xyznonexistent');

        const cards = page.locator('[data-testid="product-card"]');
        await expect(cards).toHaveCount(0);
        await expect(page.locator('.no-results')).toBeVisible();
    });

    test('clearing search shows all products again', async ({ page }) => {
        const searchInput = page.locator('[data-testid="search-input"]');

        // Filter first
        await searchInput.fill('Sneaker');
        await expect(page.locator('[data-testid="product-card"]')).toHaveCount(2);

        // Clear
        await searchInput.fill('');
        await expect(page.locator('[data-testid="product-card"]')).toHaveCount(8);
    });
});

test.describe('ShopSmart E2E — Navigation', () => {
    test('clicking Shop Now CTA scrolls to products section', async ({ page }) => {
        await page.goto('/');
        await page.getByText('Shop Now').click();

        // Products section should be in viewport after scroll
        const productsPage = page.locator('[data-testid="products-page"]');
        await expect(productsPage).toBeInViewport({ timeout: 3000 });
    });

    test('clicking Products nav link scrolls to products section', async ({ page }) => {
        await page.goto('/');
        await page.locator('.navbar').getByText('Products').click();

        const productsPage = page.locator('[data-testid="products-page"]');
        await expect(productsPage).toBeInViewport({ timeout: 3000 });
    });
});
