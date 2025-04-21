# Crypto.com Example API

A Ruby on Rails API for handling cryptocurrency transactions between users.

## Requirements

- Ruby 3.3.0
- Rails 7.2
- PostgreSQL

## Setup

1. Clone the repository:

```bash
git clone https://github.com/orbulant/crypto-com-example.git
cd crypto-com-example
```

2. Install dependencies:

```bash
bundle install
```

3. Setup database:

```bash
rails db:create
rails db:migrate
```

4. Run the server:

```bash
rails server
```

## Running Tests

### All Tests

To run all controller and model tests:

```bash
rails test:controllers test:models
```

### Specific Controller Tests

```bash
# Run all controller tests
rails test test/controllers/

# Run specific controller tests
rails test test/controllers/users_controller_test.rb
rails test test/controllers/wallets_controller_test.rb
rails test test/controllers/transactions_controller_test.rb
```

### Single Test

To run a specific test by name:

```bash
rails test test/controllers/users_controller_test.rb -n test_should_show_balance
```

## API Endpoints

Visit [Postman Collection](https://.postman.co/workspace/My-Workspace~ec23273d-039e-475e-8cbd-bce8ca3c806d/collection/29074311-4fbf8ad8-a0e8-422c-970c-a4ca5ce36af7?action=share&creator=29074311&active-environment=29074311-ee688226-0aba-4ecc-935f-226e5bb3f71d)

### Users

- `GET /users` - List all users
- `POST /users` - Create a user
- `GET /users/:id` - Show user details
- `PATCH /users/:id` - Update user
- `DELETE /users/:id` - Delete user
- `POST /users/:id/show_balance` - Show user's wallet balance
- `POST /users/:id/show_transactions` - Show user's transactions

### Wallets

- `POST /wallets/:id/deposit` - Deposit money
- `POST /wallets/:id/withdraw` - Withdraw money

### Transactions

- `POST /users/:user_id/transactions/transfer_to` - Transfer money to another user

## Example API Requests

### Create User

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "name": "Test User"}}'
```

### Deposit Money

```bash
curl -X POST http://localhost:3000/wallets/1/deposit \
  -H "Content-Type: application/json" \
  -d '{"wallet": {"amount": 100.0}}'
```

### Transfer Money

```bash
curl -X POST http://localhost:3000/users/2/transactions/transfer_to \
  -H "Content-Type: application/json" \
  -d '{"transaction": {"amount": 50.0, "sender_id": 1}}'
```

## Development

### VS Code Setup

1. Install the Ruby LSP extension by Shopfiy
2. Setup everything else unique to your hardware

### Running Tests in VS Code (this is easier)

1. Open the Testing sidebar
2. Click the play button next to the test you want to run
3. View results in the Test Explorer
