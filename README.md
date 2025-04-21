# Crypto.com Example API

> Read all the way to the end.

A super simple Ruby on Rails API for handling cryptocurrency transactions between users.

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

You may also use this Postman collection to test things out.

Visit [Postman Collection](https://.postman.co/workspace/My-Workspace~ec23273d-039e-475e-8cbd-bce8ca3c806d/collection/29074311-4fbf8ad8-a0e8-422c-970c-a4ca5ce36af7?action=share&creator=29074311&active-environment=29074311-ee688226-0aba-4ecc-935f-226e5bb3f71d)

If the collection is not accessible. There is a file in this repository where you may import into your Postman to begin.

The collection file here in this repository contains the necesssary enviroment variables to start making requests.

Begin by creating your user first and then every other API route would work.

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
curl -X POST http://localhost:3000/wallets/INSERT_WALLET_ID_HERE/deposit \
  -H "Content-Type: application/json" \
  -d '{"wallet": {"amount": 100.0}}'
```

### Transfer Money

```bash
curl -X POST http://localhost:3000/users/INSERT_THE_RECEIVING_USER_ID_HERE/transactions/transfer_to \
  -H "Content-Type: application/json" \
  -d '{"transaction": {"amount": 50.0, "sender_id": "INSERT_THE_SENDING_USER_ID_HERE"}}'
```

## Development

### VS Code Setup

1. Install the Ruby LSP extension by Shopfiy
2. Setup everything else unique to your hardware

### Running Tests in VS Code (this is easier)

1. Open the Testing sidebar
2. Click the play button next to the test you want to run
3. View results in the Test Explorer

### Explanation

explaining any decisions you made

### How should reviewer view your code?

Clone this git repository and review the files (in no particular order):

- routes.rb
- transaction.rb
- user.rb
- wallet.rb
- transaction_controller.rb
- user_controller.rb
- wallet_controller.rb

### Areas to be improved (plenty)

1. Using Golang instead

   1. Using Golang's concurrency via channels here and go routines would make this backend API a lot more scalable as it can handle a lot more transactions for a real world scenario.
   2. Move away from OOP to a more functional backend API would also mean that there is less bloat and more manual in-line code optimisations as we rely a lot less on associations and just raw data.
   3. Rails is not really built for concurrency or parallelism for high-throughput or real-time needs. If this were a real-world project, we would need to proabably use Rails for the half of the client facing product and another half be using a Golang backend connected to the database to serve out more performance intensive API endpoints.
   4. Rails has too much abstraction, thus making it slower.

2. Improving the OOP for SOLID.

   1. More distinct models (or polymorphism) should be used here to ensure the seperation of concerns.

3. Usages of `concerns` when the application grows in size to prevent repated usage of code.

4. Implement some sort of in-memory storage for faster read/writes for a real-world production use case.

5. Implement a CI/CD pipeline for this project with containersiation for a real-world production app.

6. Removal of more unused code and configurations from Rails. As we should only import what we use to keep the runtime as lightweight as possible.

7. Implement more database indexing for faster queries.

8. Implement more manual PostgreSQL queries for more raw performance instead of relying on Rails' built in ORM querying.

9. Improve Tests by utilising an testing library like RSpec/Factory Girl/FactoryBot, and rewriting them to be more reusable.

10. Using `faker` or some fake data generation tool to test trivial pieces of data like for e-mails and names.

### How long i spend on the test

- Start Time: 21st April 2025 (Monday) 6.45PM
- End Time: Time e-mail response sent.
- Actual time on development excluding rest/breaks/distractions/main-work: 5.5 hours.
- Time spent on README: 1 hour.

### Features chose not to be included

1. Adding more models such as Vendors (or Insitutions) for banks/payment providers as that would grow our code base exponentially to cater for all real world use cases.

2. Usage of polymorphism in the `transaction` model for polymorphic assocation to increase our use case for not just retail users but also institutions.

3. No in-memory storage solution. As there isn't a real-world case where that's needed here.

4. No containerisation as it would hurt the process of evaluatiing this code base more than not including it.

5. No authorisation or authentication.

6. No protected routes.

7. No UI.

8. No ability for users to create more than one wallet.

9. No ability for users to rename their wallet.
