# Scanner

Scanner is a simple Elixir and Phoenix application that allows for checking for the status of an ethereum transaction on chain

Given a transaction hash, it will return whether the transaction is `complete`, `pending` or if the transaction does not exist on chain, it returns `tx_not_found`

## Getting started

In order to run this application, you need to ensure that:

1. You have Elixir installed in your system
2. You have Postgres installed in your system
3. Clone the [Scanner Front Application](https://github.com/okariFrankline/scanner-front) and start it

If your system meets the above creteria, then you can:

1. cd into the application folder in your terminal
2. From the application folder do:

   a. Migrate the databse

   ```shell
   $ mix ecto.setup
   ```

   b. Start the server

   ```shell
    $ mix phx.server
   ```

If you wish to test the application without the react application, do the following

1. Migrate the database as shown above
2. Start the application from the application folder using:

   ```shell
   $ iex -S mix
   ```

3. From the iex terminal, do the following:

   ```shell
   iex> alias Scanner.Ethereum

   iex> tx_hash = "0x26448b745d44c9da1ffc290212af5a01bb94bdf58af1a278691a5d1f650bec45"

   iex> Ethereum.transaction_status(tx_hash)
   {:ok, :complete}

   iex> tx_hash = "non existent hash"

   iex> Ethereum.transaction_status(tx_hash)
   {:error, :tx_not_found}

   ```

4. Given that confirmation blocks required for a transaction to be complete is 2, it means it can be hard to get a response of `:pending`. Therefore, the application allows for changing of this number in the config if needed

   ```elixir
   # config/config.ex

   config :scanner,
     crawler: [
       # You can change this number to something bigger
       blocks: 2,
       module: Scanner.Spiders.Crawler
     ]
   ```

   Changing the value of `blocks` to a higher value, will allow you to get a response of `:pending` which also triggers the `Scanner.Servers.Checker` process to be started

## How it works

Whenever you call `Scanner.Ethereum.transaction_status/1` with a transaction hash, it first tries to get the tx from the db.

If it exists, it checks the current payment status performs one of two actions based on the value of the status:

1. If the status is `:complete`, it returns `{:ok, :complete}` and does not confirm it from the etherscan.io API

2. If the status is `:pending`, it does the following:

   a. Contacts the etherscan.io API by doing a webpage scrap on the transaction page of the transaction using `Crawly`.

   b. Once it get the results from the scrapping, it checks the confirmation blocks number and if greater than the allowed number, it marks the payment as `complete` and returns this as the result.

   c. However, if the confirmation blocks is less than the required:

   1. It marks the transaction as `:pending` in the db and returns that as the result
   2. It starts a `Scanner.Servers.Checker` process, which is scheduled to run every 10 seconds checking whether or not the confirmation blocks for the tx has reached the required number
   3. If they reach, the process marks the payment as `:complete` in the db and terminates itself
   4. Otherwise, it reschedules itself to un again in another 10 seconds

## Testing

In order to run the tests do:

```shell
$ mix test
```

By default, the integration tests are not run when you run the command above. In order to fix this, run:

```shell
$ mix test --include integration
```
