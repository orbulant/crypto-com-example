# Crypto.com Example API

> Read all the way to the end.

A super simple Ruby on Rails API for handling cryptocurrency transactions between users.

## How long i spend on the test

- Start Time: 21st April 2025 (Monday) 6.45PM
- End Time: 22nd April 2025 (Tuesday ) 5.PM.
- Actual time on development excluding rest/breaks/distractions/day-job: 6 hours.
- Time spent on README: 2 hour.

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
rails test
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

## Code Linting

- Please run `rubocop` to lint the code.
- Please run `rubocop -a` to auto-correct and auto-format and fix the code.

## API Endpoints

Visit [Postman Collection](https://postman.co/workspace/My-Workspace~ec23273d-039e-475e-8cbd-bce8ca3c806d/collection/29074311-4fbf8ad8-a0e8-422c-970c-a4ca5ce36af7?action=share&creator=29074311&active-environment=29074311-ee688226-0aba-4ecc-935f-226e5bb3f71d) to have the routes to test the API.

If the collection is not accessible. **There is a file in this repository where you may import into your Postman to begin.**

The collection file here in this repository contains the necesssary enviroment variables to start making requests.

Begin by creating your first and second user, get their details, copy and paste their IDs and their respective wallet ID as well into your environment, deposit money into both users and go ham!

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

## Explanation

This is an API only Rails server. It contains the following routes

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

The routes are nested by resources for users and wallets as it would make the most sense in a REST API, the transactions however is nested to the receiving user's reosource thus `/users/:user_id/transaction/transfer_to` means that we are "transfering to" the user. This is one of those Rails convention over configuration naming scheme thing that may not be ideal.

I have made sure the operations for wallets and transactions are atomic using locks so that it either performs successfully or it fails and Rails will fallback the operation, thus there wouldn't be any failed operations resulting in:

- The sender could lose money without the receiver getting it
- The transaction record could be created without actual money movement
- The receiver could get money without it being deducted from the sender

There are several CRUD routes available for us to CRUD the user. Wallets and transactions however have specific routes for deposit, withdraw for wallet and trasnfer for transaction and not the usual CRUD routes. In a real world use case, the deposit and withdraw route should not be under the wallets resources and also not allow us to directly withdraw or transfer to that wallet specifically. It should folllow the user instead as exposing the wallet ID might be a risk.

#### User Class

```ruby
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }

  before_save :downcase_email

  has_one :wallet, dependent: :destroy
  has_many :transactions, dependent: :restrict_with_error

  def as_json(options = {})
    super(options.merge(include: :wallet)) # This shouldn't be here, i included it in so that we can easily get the wallet details
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
```

The user class here has some basic validation and each user can only ever have one wallet, which is created and saved everytime a user is created. The user also has many transactions.

For wallet: Using `dependent: :destroy` is correct because when a user is deleted, their wallet should also be deleted since it doesn't make sense to have orphaned wallets.

For transactions: Using `dependent: :restrict_with_error` is correct because:

- Transaction records are important for audit purposes
- They represent financial history that should not be deleted
- If a user needs to be deleted, then we should consider how we wanna approach this, maybe by just setting a "is_disabled" flag instead and not truly allowing for deletion. This would depend on data laws and what we are tryin to accomplish.

#### Wallet Class

```ruby
class Wallet < ApplicationRecord
  belongs_to :user

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true, length: { maximum: 255 }

  has_many :transactions, dependent: :restrict_with_error
end
```

The wallet class here has some basic validation but most important belongs to a user but has many transactions, so we can run `@user.wallet.transactions` to see all the transactions made coming IN to the account. Much like the user class, transactions here are preserved for audit trails, legal compliance, financial record-keeping and dispute resolutions. If we truly want to delete this wallet. We would have to come up proper use case much like the User class above.

#### Transaction Class

```ruby
class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
```

The transactions class here has simple validations and most importantly belongs to a wallet and a user. Since the association with both wallet and user is already enforced and restricted, there should never be an orphaned record of transaction thus this should be compliant with auditing needs.

### Final Notes

As for the rest of the application, please refer to the controllers and test files for more explanation.

## How should reviewer view your code?

> Please check out the tests, or Postman collection or controller route params to see what kind of payload should be passed in to the routes. They are simple enough like:

```json
// Create new user
{
  "user": {
    "email": "another@hello.com",
    "name": "My Second User"
  }
}

// Deposit
{
    "wallet": {
        "amount": 1000.0
    }
}

// Transfer to
{
    "transaction": {
        "sender_id": "<<INCLUDE_USER_ID_HERE>>",
        "amount": 100.0
    }
}
```

Clone this git repository and review the files (in no particular order):

- routes.rb
- transaction.rb
- user.rb
- wallet.rb
- transaction_controller.rb
- user_controller.rb
- wallet_controller.rb

## Areas to be improved (plenty)

1. Using Golang instead

   1. Using Golang's concurrency via channels here and go routines would make this backend API a lot more scalable as it can handle a lot more transactions for a real world scenario.
   2. Move away from OOP to a more functional backend API would also mean that there is less bloat and more manual in-line code optimisations as we rely a lot less on associations and just raw data.
   3. Rails is not really built for concurrency or parallelism for high-throughput or real-time needs. If this were a real-world project, we would need to proabably use Rails for the half of the client facing product and another half be using a Golang backend connected to the database to serve out more performance intensive API endpoints.
   4. Rails has too much abstraction, thus making it slower.
   5. Rails implementation of atomic transactions are slower.

2. Improving the OOP for SOLID.

   1. More distinct models (or polymorphism) should be used here to ensure the seperation of concerns.

3. Usages of `concerns` when the application grows in size to prevent repated usage of code.

4. Implement some sort of in-memory storage for faster read/writes for a real-world production use case.

5. Implement a CI/CD pipeline for this project with containersiation for a real-world production app.

6. Removal of more unused code and configurations from Rails. As we should only import what we use to keep the runtime as lightweight as possible.

7. Implement more database indexing for faster queries.

8. Implement more manual PostgreSQL queries for more raw performance instead of relying on Rails' built in ORM querying.

9. Improve Tests by utilising an testing library like RSpec/Factory Girl/FactoryBot, and rewriting them to be more reusable.

10. Using `faker` or some fake data generation tool to test trivial pieces of data like for e-mails and names so that the tests are more robust.

11. If more data and visiblity is required, we may want to add in a better way for distinguishing incoming and outgoing transactions, the way it is in the current project is to keep it as lightweight as possible.

12. Deposit and withdraw magically creates money out of thin air which shouldn't make sense. Ideally, there should be an existing User model or a new Vendor model that already has a pre set amount of balance (such as from a payment gateway, institution, bank etc.)

13. Ensure more security and integrity so that we do not ending up creating a system where the audit trails show that money is created out of thin air, this can be done by creating a separate balance sheet table or something similar to keep track of amount flows and for accounting.

## Features chose not to be included

1. Adding more models such as Vendors (or Insitutions) for banks/payment providers as that would grow our code base exponentially to cater for all real world use cases.

2. Usage of polymorphism in the `transaction` model for polymorphic assocation to increase our use case for not just retail users but also institutions.

3. No in-memory storage solution. As there isn't a real-world case where that's needed here.

4. No containerisation as it would hurt the process of evaluating this code base more than not including it.

5. No authorisation or authentication.

6. No protected routes.

7. No UI.

8. No ability for users to create more than one wallet.

9. No ability for users to rename their wallet.

10. No API versioning here (i.e., routes that begin with `/v1/...`) as the use case is minimal.

11. Not an RPC backend for internal communication. This project is a REST API.

12. No jobs queue for transactions and making users wait until the transaction has succeeded.
