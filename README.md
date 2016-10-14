# CookieStore

Cookie storage in a GenServer; optionally persisted to disk.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `cookie_store` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:cookie_store, "~> 0.1.0"}]
    end
    ```

  2. Ensure `cookie_store` is started before your application:

    ```elixir
    def application do
      [applications: [:cookie_store]]
    end
    ```

  3. Add a CookieStore to your supervisor hierarchy:

    ```elixir
    worker(CookieStore, [name: MyStore])
    ```

Optionally, persist the cookies between server restarts:


    ```elixir
    worker(CookieStore, [[name: MyStore, statefile: "/tmp/cookies.dat"]])
    ```
