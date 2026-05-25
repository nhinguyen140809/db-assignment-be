# CrabFood Backend

Backend API for **CrabFood**, a food delivery platform. Built with NestJS, Prisma ORM, and SQL Server.

## Tech Stack

- **NestJS** — REST API framework
- **Prisma 6** — ORM and database toolkit
- **SQL Server 2022** — relational database (runs via Docker)
- **JWT + Passport** — authentication
- **Swagger** — auto-generated API documentation

## Project Structure

```
db-assignment-be/
├── src/
│   ├── main.ts                        # App entry point — bootstraps NestJS, registers Swagger,
│   │                                  #   global validation pipe, JWT guard, and CORS
│   ├── app.module.ts                  # Root module — wires all feature modules together
│   ├── typings/
│   │   └── global.d.ts                # Global TypeScript declarations (e.g. Express Request augmentation)
│   ├── common/
│   │   └── decorators/
│   │       ├── current-user.decorator.ts  # @CurrentUser() — extracts the authenticated user from the request
│   │       └── public.decorator.ts        # @Public() — marks a route as unauthenticated
│   ├── database/
│   │   ├── prisma.module.ts           # Global NestJS module that provides PrismaService app-wide
│   │   └── prisma.service.ts          # Wraps PrismaClient; handles connection lifecycle
│   └── modules/                       # Feature modules — one per business domain
│       ├── auth/
│       │   ├── auth.controller.ts     # POST /auth/register, /auth/login, /auth/refresh
│       │   ├── auth.service.ts        # Register, login, refresh token logic
│       │   ├── dtos/                  # LoginDto, RegisterDto — request body validation
│       │   ├── interfaces/            # JwtPayload, AuthResponseDetails types
│       │   ├── guards/
│       │   │   └── global-jwt-auth.guard.ts  # Applied globally — protects all routes by default
│       │   └── strategies/
│       │       └── jwt.strategy.ts    # Passport JWT strategy — validates Bearer tokens
│       ├── users/
│       │   ├── users.controller.ts    # User profile and payment method endpoints
│       │   ├── users.service.ts       # User CRUD, password hashing, role resolution
│       │   ├── dtos/                  # UserDto, PaymentMethodDto
│       │   └── interfaces/            # UserDetails type
│       ├── restaurants/
│       │   ├── restaurants.controller.ts  # Restaurant listing, search, details
│       │   ├── restaurants.service.ts     # Queries restaurants with operating hours and menu
│       │   ├── dtos/                      # RestaurantDto
│       │   └── interfaces/                # RestaurantDetails type
│       ├── menu/
│       │   ├── menu.controller.ts     # Menu item endpoints (browse, favourites)
│       │   ├── menu.service.ts        # Menu item queries and favourite management
│       │   ├── dtos/                  # MenuItemDto
│       │   └── interfaces/            # MenuItemDetails type
│       ├── orders/
│       │   ├── orders.controller.ts   # Order lifecycle endpoints (create, update, pay)
│       │   ├── orders.service.ts      # Order creation, status transitions, payment recording
│       │   ├── dtos/                  # OrderDto, OrderItemDto
│       │   └── interfaces/            # OrderDetails type
│       └── address/
│           ├── address.controller.ts  # Delivery address CRUD
│           ├── address.service.ts     # Address management per customer
│           ├── dtos/                  # AddressDto
│           └── interfaces/            # AddressDetails type
│
├── prisma/
│   └── schema.prisma              # Prisma schema — introspected from the live DB (do not edit by hand)
│
├── db/                            # SQL scripts — define the full database from scratch
│   ├── create_db.sql              # Creates the CrabFood database
│   ├── 01_type/                   # Custom SQL types (IDType, MoneyType, etc.)
│   ├── 02_sequence/               # Sequences for ID generation
│   ├── 03_table/                  # All table definitions
│   ├── 04_constraint/             # CHECK, PRIMARY KEY, UNIQUE constraints
│   ├── 05_relation/               # Foreign key relationships
│   ├── 06_function/               # Scalar/table-valued functions (search, derived fields)
│   ├── 07_procedure/              # Stored procedures (insert operations)
│   ├── 08_trigger/                # Triggers (business rules, derived field updates)
│   └── 09_data/                   # Seed data (initial + sample records)
│
├── docker/
│   └── init-db.sh                 # Container entrypoint — starts SQL Server, waits for readiness,
│                                  #   then runs all db/ scripts in order on first start
├── docker-compose.yml             # Spins up SQL Server 2022 with persistent named volume
│
├── package.json
├── tsconfig.json
└── nest-cli.json
```

## Key Design

### Secure by default
JWT authentication is enforced globally via `GlobalJwtAuthGuard`. Every route requires a valid Bearer token unless explicitly marked with `@Public()`. This means new endpoints are protected automatically without any extra configuration.

### Feature module layout
Each business domain (`auth`, `users`, `restaurants`, `menu`, `orders`, `address`) lives in its own NestJS module with a consistent internal structure: controller → service → DTOs → interfaces. The controller handles routing and input validation; the service handles business logic and Prisma queries.

### Single shared database connection
`PrismaModule` is registered as a global module, so `PrismaService` is injected once and shared across all feature modules — no per-module database setup needed.

### Schema introspected from the database
`schema.prisma` is generated by running `prisma db pull` against the live SQL Server instance — it is not written by hand. The SQL scripts in `db/` are the source of truth for the database structure; the Prisma schema is derived from them.

### SQL scripts run in dependency order
`init-db.sh` executes the `db/` scripts in numbered folder order: types → sequences → tables → constraints → relations → functions → procedures → triggers → seed data. This ensures every dependency exists before it is referenced.

### DTO validation is strict
All request bodies pass through NestJS's `ValidationPipe` with `whitelist: true` and `forbidNonWhitelisted: true`. Unknown properties are rejected outright rather than silently ignored.

## Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [Docker](https://www.docker.com/) with Docker Compose

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Configure environment

Copy the example and fill in your values:

```bash
cp .env.example .env
```

Default `.env` for local Docker:

```env
NODE_ENV=development
DATABASE_URL="sqlserver://localhost:1433;database=CrabFood;user=sa;password=Vdnak2005!;encrypt=true;trustServerCertificate=true"
JWT_SECRET="your_jwt_secret"
PORT=3000
```

### 3. Start the database

```bash
docker compose up -d
```

On first run, the container automatically creates the `CrabFood` database and runs all SQL scripts. Watch the logs to confirm:

```bash
docker compose logs -f
# wait for: "Database initialization complete!"
```

On subsequent starts, existing data is preserved via the named Docker volume.

### 4. Pull the schema and generate the Prisma client

```bash
npm run prisma:pull       # introspect the live DB into schema.prisma
npm run prisma:generate  # generate the TypeScript client
```

### 5. Run the application

```bash
# development (watch mode)
npm run start:dev

# production
npm run start:prod
```

The API runs at `http://localhost:3000` by default.
Swagger docs are available at `http://localhost:3000/api`.

## Database Commands

| Command | Description |
|---|---|
| `docker compose up -d` | Start SQL Server |
| `docker compose down` | Stop SQL Server (data preserved) |
| `docker compose down -v` | Stop and delete all data (clean reset) |
| `npm run prisma:pull` | Sync schema.prisma from the running DB |
| `npm run prisma:generate` | Regenerate the Prisma client |
| `npm run prisma:studio` | Open Prisma Studio at http://localhost:5555 |

## Resetting the Database

To wipe all data and re-run the SQL scripts from scratch:

```bash
docker compose down -v   # removes the named volume
docker compose up -d     # re-initializes the DB with the SQL scripts
npm run prisma:pull       # update schema.prisma to match the new DB
npm run prisma:generate  # regenerate the Prisma client
```
