# Source Code

This directory contains the source code for all microservices in the Online Boutique application.

## Microservices

| Service | Language | Description |
|---------|----------|-------------|
| [frontend](./frontend) | Go | Web UI and external API endpoint |
| [cartservice](./cartservice) | C# | Shopping cart data management |
| [productcatalogservice](./productcatalogservice) | Go | Product catalog management |
| [currencyservice](./currencyservice) | Node.js | Currency conversion |
| [paymentservice](./paymentservice) | Node.js | Payment processing |
| [shippingservice](./shippingservice) | Go | Shipping cost calculation |
| [emailservice](./emailservice) | Python | Order confirmation emails |
| [checkoutservice](./checkoutservice) | Go | Order processing orchestration |
| [recommendationservice](./recommendationservice) | Python | Product recommendations |
| [adservice](./adservice) | Java | Targeted ad serving |
| [loadgenerator](./loadgenerator) | Python | Load testing |
| [shoppingassistantservice](./shoppingassistantservice) | Python | AI shopping assistant |

## Key Features

- gRPC communication between services
- Redis-based cart storage
- REST/JSON external API
- Distributed tracing and metrics
- Multi-language implementation

## Local Development

1. Copy `env.template` to `.env` in the root directory
2. Configure environment variables
3. Run `docker-compose up` to start all services

For service-specific instructions, see the README in each service directory. 