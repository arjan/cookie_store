# CookieStore

Cookie storage in a GenServer; optionally persisted to disk.

## Installation

The package can be installed as follows:

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
    worker(CookieStore, [[name: MyStore]])
    ```

## Usage

By now, you can store cookies retrieved from a http request as
follows, e.g. using the Poison library:

    response = HTTPoison.get!(url)
    :ok = CookieStore.store(MyStore, "example.com", response.headers)

Later, when you want to do a new HTTP request, but using the cookies
saved in the previous request, do:

    headers = %{"Cookie": CookieStore.as_header(MyStore, "example.com")}
    response = HTTPoison.get!("http://example.com/.....", headers)


If you want the cookie store to be persisted between application
restarts, pass a `statefile` option to the worker:

    ```elixir
    worker(CookieStore, [[name: MyStore, statefile: "/tmp/cookies.dat"]])
    ```
