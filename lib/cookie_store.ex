defmodule CookieStore do
  use GenServer


  defmodule Cookie do
    defstruct name: nil, value: nil, path: nil, domain: nil, expires: nil, secure: false

    def str(cookie) do
      "#{cookie.name}=#{cookie.value}"
    end
  end


  @statefile "/tmp/cookiestore.dat"

  def start_link(opts \\ []) do
    start_opts = if is_atom(opts[:name]) do
      [name: opts[:name]]
    else
      []
    end
    GenServer.start_link(__MODULE__, opts, start_opts)
  end

  def retrieve(store, domain, secure_only \\ false) do
    GenServer.call(store, {:retrieve, domain, secure_only})
  end

  def as_header(store, domain, secure_only \\ false) do
    retrieve(store, domain, secure_only)
    |> Enum.reduce([], fn({_, c}, acc) ->
      if acc == [] do
        Cookie.str(c)
      else
        [acc, "; ", Cookie.str(c)]
      end
    end)
    |> IO.iodata_to_binary
  end

  def store(store, domain, headers) do
    GenServer.call(store, {:store, domain, headers})
  end

  ## server API

  defmodule State do
    defstruct cookies: %{}, statefile: nil
  end

  def init(opts) do
    state = %State{statefile: opts[:statefile]}
    {:ok, load_state(state)}
  end

  def handle_call({:retrieve, domain, _secure_only}, _from, state) do
    {:reply, state.cookies[domain] || %{}, state}
  end

  def handle_call({:store, domain, headers}, _from, state) do
    domain_cookies = (state.cookies[domain] || %{})
    |> Map.merge(parse_cookies(headers))
    newcookies = Map.put(state.cookies, domain, domain_cookies)
    state = %State{state | cookies: newcookies}
    {:reply, :ok, save_state(state)}
  end

  defp parse_cookies(headers) do
    headers
    |> Enum.filter(fn({k, _}) -> String.downcase(k) == "set-cookie" end)
    |> Enum.map(fn({_, v}) ->
      [kv | opts] = Regex.split(~r/\s*;\s*/, String.trim(v))
      [name, value] = String.split(kv, "=", parts: 2)
      cookie = opts |> Enum.reduce(
        %Cookie{name: name, value: value},
        fn(opt, cookie) ->
          case opt do
            "path=" <> path ->
              %{cookie | path: path};
            "domain=" <> domain ->
              %{cookie | domain: domain};
            "expires=" <> _expires ->
              # FIXME date parsing
              cookie
            "secure" ->
              %{cookie | secure: true};
            _other ->
              cookie
          end
        end)
      {name, cookie}
    end)
    |> Enum.into(%{})
  end


  defp load_state(state = %State{statefile: nil}) do
    state
  end
  defp load_state(state) do
    cookies = case File.exists?(state.statefile) do
                true ->
                  :erlang.binary_to_term(File.read!(state.statefile))
                false ->
                  %{}
              end
    %State{state | cookies: cookies}
  end

  defp save_state(state = %State{statefile: nil}) do
    state
  end
  defp save_state(state) do
    File.write!(state.statefile, :erlang.term_to_binary(state.cookies))
    state
  end

end
