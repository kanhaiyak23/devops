const request = require('supertest');
const app = require('../src/app');

describe('GET /api/health', () => {
    it('should return 200 and status ok', async () => {
        const res = await request(app).get('/api/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('status', 'ok');
    });
});

describe('GET /api/products', () => {
    it('should return 200 with an array of products', async () => {
        const res = await request(app).get('/api/products');
        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it('each product should have required fields', async () => {
        const res = await request(app).get('/api/products');
        const product = res.body[0];
        expect(product).toHaveProperty('id');
        expect(product).toHaveProperty('name');
        expect(product).toHaveProperty('price');
        expect(product).toHaveProperty('category');
        expect(product).toHaveProperty('description');
    });
});

describe('GET /api/products/search', () => {
    it('should return filtered results for matching query', async () => {
        const res = await request(app).get('/api/products/search?q=sneaker');
        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
        res.body.forEach(product => {
            const nameOrCategory = (product.name + ' ' + product.category).toLowerCase();
            expect(nameOrCategory).toContain('sneaker');
        });
    });

    it('should return empty array for non-matching query', async () => {
        const res = await request(app).get('/api/products/search?q=xyznonexistent');
        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBe(0);
    });

    it('should return all products when no query is provided', async () => {
        const res = await request(app).get('/api/products/search');
        expect(res.statusCode).toEqual(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it('should be case insensitive', async () => {
        const res = await request(app).get('/api/products/search?q=DENIM');
        expect(res.statusCode).toEqual(200);
        expect(res.body.length).toBeGreaterThan(0);
        expect(res.body[0].name).toContain('Denim');
    });
});
