# Source Code

## Service Architecture

![Container Structure](/docs/images/c4-container-internal.png)

## Microservices

### Frontend & API
- **frontend** (Go): Web UI and external API endpoint
- **adservice** (Java): Targeted ad serving
- **shoppingassistantservice** (Python): AI shopping assistant

### Core Services
- **productcatalogservice** (Go): Product catalog management
- **cartservice** (C#): Shopping cart data management
- **checkoutservice** (Go): Order processing orchestration

### Supporting Services
- **currencyservice** (Node.js): Currency conversion
- **paymentservice** (Node.js): Payment processing
- **shippingservice** (Go): Shipping cost calculation
- **emailservice** (Python): Order confirmation emails
- **recommendationservice** (Python): Product recommendations

## Local Development

1. Copy `env.template` to `.env` in the root directory
2. Configure environment variables
3. Run `docker-compose up` to start all services

For service-specific instructions, see each service's directory.