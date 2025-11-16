# CLAUDE.md - AI Assistant Guide for Dropshipping System

## Repository Overview

This repository contains a **Dropshipping System** - a comprehensive e-commerce solution for managing dropshipping operations. The system is currently in its initial stages of development.

### Project Purpose
A dropshipping system that facilitates:
- Product sourcing and catalog management
- Order processing and fulfillment
- Supplier integration and management
- Inventory synchronization
- Customer order tracking
- Multi-channel sales integration
- Automated pricing and profit margin calculations

## Current Repository State

**Status**: Initial setup - repository contains only README.md
**Branch Strategy**: Feature branches with `claude/` prefix
**Active Branch**: `claude/claude-md-mi21ls131pobx4i9-01YAFCuJkFkLrsDXztMtiKX4`

## Expected Project Structure

When development begins, the typical structure should follow this pattern:

```
dropshipping-system/
├── backend/                    # Backend API services
│   ├── src/
│   │   ├── controllers/       # API endpoint handlers
│   │   ├── models/            # Data models and schemas
│   │   ├── services/          # Business logic
│   │   ├── routes/            # API route definitions
│   │   ├── middleware/        # Express/API middleware
│   │   ├── config/            # Configuration files
│   │   └── utils/             # Utility functions
│   ├── tests/                 # Backend tests
│   └── package.json
│
├── frontend/                   # Frontend application
│   ├── src/
│   │   ├── components/        # Reusable UI components
│   │   ├── pages/             # Page components
│   │   ├── hooks/             # Custom React hooks
│   │   ├── services/          # API client services
│   │   ├── store/             # State management
│   │   ├── utils/             # Frontend utilities
│   │   └── assets/            # Static assets
│   ├── public/
│   └── package.json
│
├── shared/                     # Shared code between frontend/backend
│   ├── types/                 # TypeScript type definitions
│   └── constants/             # Shared constants
│
├── database/                   # Database related files
│   ├── migrations/            # Database migrations
│   ├── seeds/                 # Seed data
│   └── schemas/               # Database schemas
│
├── docs/                       # Documentation
│   ├── api/                   # API documentation
│   ├── architecture/          # Architecture diagrams
│   └── guides/                # User and developer guides
│
├── scripts/                    # Build and deployment scripts
├── .github/                    # GitHub workflows and templates
├── docker/                     # Docker configuration
├── .env.example               # Environment variable template
├── docker-compose.yml         # Docker compose configuration
├── README.md                  # Project overview
└── CLAUDE.md                  # This file
```

## Technology Stack Recommendations

### Backend
- **Runtime**: Node.js (v18+) or Python (3.11+)
- **Framework**: Express.js, NestJS, FastAPI, or Django
- **Database**: PostgreSQL (primary), Redis (caching)
- **ORM**: Prisma, TypeORM, SQLAlchemy, or Django ORM
- **Authentication**: JWT, OAuth 2.0
- **API Style**: RESTful or GraphQL

### Frontend
- **Framework**: React (Next.js) or Vue.js (Nuxt)
- **Language**: TypeScript
- **State Management**: Redux Toolkit, Zustand, or Pinia
- **Styling**: Tailwind CSS, Material-UI, or Ant Design
- **Build Tool**: Vite or Next.js built-in

### Infrastructure
- **Containerization**: Docker, Docker Compose
- **API Documentation**: OpenAPI/Swagger or GraphQL Schema
- **Testing**: Jest, Vitest, Pytest, or Django Test
- **CI/CD**: GitHub Actions

## Development Workflow

### 1. Branch Management
- **Main Branch**: `main` or `master` (production-ready code)
- **Feature Branches**: `claude/claude-md-*` pattern for AI-assisted development
- **Branch Naming**: Use descriptive names: `feature/order-processing`, `fix/supplier-sync`, `refactor/api-routes`

### 2. Commit Conventions
Follow Conventional Commits specification:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Test additions/modifications
- `chore:` Maintenance tasks
- `perf:` Performance improvements

Example:
```
feat: add supplier API integration
fix: resolve order synchronization issue
docs: update API endpoint documentation
```

### 3. Code Quality Standards
- **Linting**: ESLint (JavaScript/TypeScript), Pylint/Black (Python)
- **Formatting**: Prettier (JavaScript/TypeScript), Black (Python)
- **Type Safety**: Strict TypeScript configuration, Python type hints
- **Testing**: Minimum 80% code coverage for critical paths
- **Code Review**: All changes reviewed before merge

### 4. Git Operations
```bash
# Fetch latest changes
git fetch origin <branch-name>

# Create feature branch
git checkout -b feature/your-feature

# Commit changes
git add .
git commit -m "feat: your descriptive message"

# Push to remote
git push -u origin <branch-name>
```

## Key Conventions for AI Assistants

### 1. Code Style
- **Naming Conventions**:
  - `camelCase` for variables and functions (JavaScript/TypeScript)
  - `PascalCase` for classes and components
  - `UPPER_SNAKE_CASE` for constants
  - `snake_case` for Python functions and variables

- **File Naming**:
  - Components: `PascalCase.tsx` or `PascalCase.jsx`
  - Utilities: `kebab-case.ts` or `camelCase.ts`
  - Tests: `*.test.ts` or `*.spec.ts`

### 2. Security Best Practices
- **Never commit sensitive data**: API keys, passwords, tokens
- **Use environment variables**: Store all configuration in `.env` files
- **Input validation**: Validate all user inputs on both frontend and backend
- **SQL injection prevention**: Use parameterized queries or ORM
- **XSS protection**: Sanitize user-generated content
- **Authentication**: Implement proper JWT validation and refresh tokens
- **Rate limiting**: Protect API endpoints from abuse
- **CORS**: Configure properly for production

### 3. API Design Principles
- **RESTful conventions**:
  - GET: Retrieve resources
  - POST: Create resources
  - PUT/PATCH: Update resources
  - DELETE: Remove resources

- **Status codes**:
  - 200: Success
  - 201: Created
  - 400: Bad request
  - 401: Unauthorized
  - 403: Forbidden
  - 404: Not found
  - 500: Server error

- **Response format**:
```json
{
  "success": true,
  "data": {},
  "message": "Operation successful",
  "timestamp": "2025-11-16T00:00:00Z"
}
```

### 4. Database Conventions
- **Table naming**: Plural, snake_case (`orders`, `product_variants`)
- **Column naming**: snake_case (`created_at`, `user_id`)
- **Primary keys**: `id` (integer or UUID)
- **Foreign keys**: `<table>_id` pattern (`user_id`, `order_id`)
- **Timestamps**: Include `created_at` and `updated_at`
- **Soft deletes**: Use `deleted_at` for soft deletion

### 5. Error Handling
- **Backend**: Centralized error handling middleware
- **Frontend**: Error boundaries for React components
- **Logging**: Structured logging with appropriate levels (error, warn, info, debug)
- **User feedback**: Clear, actionable error messages

### 6. Testing Strategy
- **Unit tests**: Test individual functions and components
- **Integration tests**: Test API endpoints and database interactions
- **E2E tests**: Test complete user workflows
- **Test structure**: Arrange-Act-Assert pattern

Example test:
```typescript
describe('Order Service', () => {
  it('should create an order successfully', async () => {
    // Arrange
    const orderData = { productId: 1, quantity: 2 };

    // Act
    const result = await orderService.createOrder(orderData);

    // Assert
    expect(result.status).toBe('pending');
    expect(result.quantity).toBe(2);
  });
});
```

## Dropshipping-Specific Considerations

### 1. Core Entities
- **Products**: SKU, title, description, images, pricing, variants
- **Orders**: Customer info, line items, status, tracking
- **Suppliers**: Contact info, API credentials, product catalog
- **Inventory**: Stock levels, synchronization frequency
- **Customers**: Contact info, order history, preferences
- **Shipping**: Carriers, rates, tracking numbers

### 2. Integration Points
- **Supplier APIs**: AliExpress, Oberlo, Spocket, CJDropshipping
- **Sales Channels**: Shopify, WooCommerce, Amazon, eBay
- **Payment Gateways**: Stripe, PayPal, Square
- **Shipping Carriers**: USPS, FedEx, UPS, DHL
- **Analytics**: Google Analytics, custom dashboards

### 3. Critical Workflows
1. **Product Import**: Sync products from suppliers to catalog
2. **Order Processing**: Receive order → Create supplier order → Track shipment
3. **Inventory Sync**: Regular synchronization with supplier inventory
4. **Price Calculation**: Cost + margin + shipping = retail price
5. **Order Fulfillment**: Automated or manual supplier notification
6. **Tracking Updates**: Sync tracking info from supplier to customer

### 4. Business Logic
- **Profit Margin Calculation**: Configurable margin rules per category/supplier
- **Automated Repricing**: Adjust prices based on supplier cost changes
- **Multi-currency Support**: Handle international transactions
- **Tax Calculations**: Regional tax compliance
- **Returns Processing**: Manage returns and refunds

## Documentation Requirements

### For New Features
1. **Code comments**: JSDoc/TSDoc for functions, complex logic explanations
2. **API documentation**: Update OpenAPI/Swagger specs
3. **README updates**: Update if user-facing changes
4. **Migration guides**: Document breaking changes

### For Bug Fixes
1. **Issue reference**: Link to GitHub issue in commit message
2. **Root cause**: Explain what caused the bug
3. **Solution**: Describe the fix approach
4. **Test coverage**: Add tests to prevent regression

## Performance Guidelines

1. **Database queries**: Use indexes, avoid N+1 queries
2. **API responses**: Pagination for large datasets
3. **Caching**: Redis for frequently accessed data
4. **Asset optimization**: Compress images, lazy load components
5. **Bundle size**: Code splitting, tree shaking
6. **Rate limiting**: Protect against API abuse

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] Static assets built and optimized
- [ ] Security headers configured
- [ ] SSL/TLS certificates installed
- [ ] Backup strategy implemented
- [ ] Monitoring and alerting setup
- [ ] Rate limiting configured
- [ ] CORS policies set
- [ ] Error tracking enabled (Sentry, etc.)

## AI Assistant Guidelines

### When Starting Work
1. **Read this file first**: Understand project conventions
2. **Check existing code**: Follow established patterns
3. **Review recent commits**: Understand current development direction
4. **Ask for clarification**: If requirements are ambiguous

### During Development
1. **Use TodoWrite**: Track multi-step tasks
2. **Follow conventions**: Adhere to coding standards
3. **Write tests**: Include tests with new features
4. **Document changes**: Update relevant documentation
5. **Security first**: Always consider security implications
6. **Commit frequently**: Small, atomic commits with clear messages

### Before Completing
1. **Run tests**: Ensure all tests pass
2. **Check linting**: No linting errors
3. **Review changes**: Self-review your code
4. **Update docs**: Ensure documentation is current
5. **Clean up**: Remove debug code, console.logs
6. **Commit and push**: Push to the correct branch

### Common Pitfalls to Avoid
- ❌ Hardcoding sensitive credentials
- ❌ Skipping input validation
- ❌ Ignoring error handling
- ❌ Not writing tests
- ❌ Creating overly complex solutions
- ❌ Ignoring existing patterns
- ❌ Pushing to wrong branch
- ❌ Large, monolithic commits

## Resources

### Documentation to Create
- API documentation (OpenAPI/Swagger)
- Database schema diagrams
- Architecture decision records (ADRs)
- User guides and tutorials
- Development setup guide

### External Resources
- [REST API Best Practices](https://restfulapi.net/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [React Best Practices](https://react.dev/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

## Questions and Support

For questions about:
- **Architecture decisions**: Review existing patterns or ask for clarification
- **Technology choices**: Consider project requirements and team expertise
- **Business logic**: Understand dropshipping workflows before implementing
- **Unclear requirements**: Always ask rather than assume

## Version History

- **v1.0.0** (2025-11-16): Initial CLAUDE.md creation for new repository

---

**Last Updated**: 2025-11-16
**Maintained By**: AI Assistants and Project Contributors
**Status**: Living document - update as project evolves
