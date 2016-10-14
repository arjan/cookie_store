defmodule CookieStoretest do
  use ExUnit.Case

  @domain "example.com"
  @domain2 "anotherexample.com"

  @headers [{"Server", "GitHub.com"}, {"Date", "Thu, 13 Oct 2016 08:04:25 GMT"}, {"Content-Type", "text/html; charset=utf-8"}, {"Transfer-Encoding", "chunked"}, {"Status", "200 OK"}, {"Cache-Control", "no-cache"}, {"X-GitHub-User", "testuser"}, {"X-GitHub-Session-Id", "127049720"}, {"Vary", "X-PJAX"}, {"X-UA-Compatible", "IE=Edge,chrome=1"}, {"Set-Cookie", "user_session=okdaIIfuudoosCJrssUp5tHXCVQcm0nmwnPF_8u2l7OYSPV_W9W00w9d73sf6gUXAkyhE_Mk7aRMuhZz; path=/; expires=Thu, 27 Oct 2016 08:04:25 -0000; secure; HttpOnly"}, {"Set-Cookie", "__Host-user_session_same_site=okdaIIfuudoosCJrssUp5tHXCVQcm0nmwnPF_8u2l7OYSPV_W9W00w9d73sf6gUXAkyhE_Mk7aRMuhZz; path=/; expires=Thu, 27 Oct 2016 08:04:25 -0000; secure; HttpOnly"}, {"Set-Cookie", "logged_in=yes; domain=.github.com; path=/; expires=Mon, 13 Oct 2036 08:04:25 -0000; secure; HttpOnly"}, {"Set-Cookie", "dotcom_user=testuser; domain=.github.com; path=/; expires=Mon, 13 Oct 2036 08:04:25 -0000; secure; HttpOnly"}, {"X-Request-Id", "0c2ed1ddb916bfe32612f8cb7fd3caec"}, {"X-Runtime", "0.197406"}, {"Content-Security-Policy", "default-src 'none'; base-uri 'self'; block-all-mixed-content; child-src render.githubusercontent.com; connect-src 'self' uploads.github.com status.github.com api.github.com www.google-analytics.com github-cloud.s3.amazonaws.com wss://live.github.com; font-src assets-cdn.github.com; form-action 'self' github.com gist.github.com; frame-ancestors 'none'; frame-src render.githubusercontent.com; img-src 'self' data: assets-cdn.github.com identicons.github.com collector.githubapp.com github-cloud.s3.amazonaws.com *.githubusercontent.com; media-src 'none'; script-src assets-cdn.github.com; style-src 'unsafe-inline' assets-cdn.github.com"}, {"Strict-Transport-Security", "max-age=31536000; includeSubdomains; preload"}, {"Public-Key-Pins", "max-age=5184000; pin-sha256=\"WoiWRyIOVNa9ihaBciRSC7XHjliYS9VwUGOIud4PB18=\"; pin-sha256=\"RRM1dGqnDFsCJXBTHky16vi1obOlCgFFn/yOhI/y+ho=\"; pin-sha256=\"k2v657xBsOVe1PQRwOsHsw3bsGT2VzIqz5K+59sNQws=\"; pin-sha256=\"K87oWBWM9UZfyddvDfoxL+8lpNyoUB2ptGtn0fv6G2Q=\"; pin-sha256=\"IQBnNBEiFuhj+8x6X8XLgh01V9Ic5/V3IRQLNFFc7v4=\"; pin-sha256=\"iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=\"; pin-sha256=\"LvRiGEjRqfzurezaWuj8Wie2gyHMrW5Q06LspMnox7A=\"; includeSubDomains"}, {"X-Content-Type-Options", "nosniff"}, {"X-Frame-Options", "deny"}, {"X-XSS-Protection", "1; mode=block"}, {"Vary", "Accept-Encoding"}, {"X-Served-By", "9835a984a05caa405eb61faaa1546741"}, {"X-GitHub-Request-Id", "D9131F06:10CE3:7984285:57FF4008"}]

  setup do
    {:ok, store} = CookieStore.start_link()
    {:ok, %{store: store}}
  end


  test "set cookies based on headers", %{store: store} do
    :ok = CookieStore.store(store, @domain, @headers)

    cookies = CookieStore.retrieve(store, @domain)

    assert "testuser" == cookies["dotcom_user"].value
    assert "okdaIIfuudoosCJrssUp5tHXCVQcm0nmwnPF_8u2l7OYSPV_W9W00w9d73sf6gUXAkyhE_Mk7aRMuhZz" == cookies["user_session"].value
    assert "/" == cookies["user_session"].path

  end


  test "updating cookie value", %{store: store} do
    :ok = CookieStore.store(store, @domain, [{"set-cookie", "foo=bar"}])
    assert "bar" == CookieStore.retrieve(store, @domain)["foo"].value

    :ok = CookieStore.store(store, @domain, [{"set-cookie", "foo=baz"}])
    assert "baz" == CookieStore.retrieve(store, @domain)["foo"].value
  end


  test "save state between genserver crash / restart" do

    {:ok, store1} = CookieStore.start_link(statefile: "/tmp/test.state")
    :ok = CookieStore.store(store1, @domain, [{"set-cookie", "foo=123"}])
    assert "123" == CookieStore.retrieve(store1, @domain)["foo"].value

    Process.flag(:trap_exit, true)
    Process.exit(store1, :kill)

    {:ok, store1} = CookieStore.start_link(statefile: "/tmp/test.state")

    assert "123" == CookieStore.retrieve(store1, @domain)["foo"].value

  end

  test "as_header", %{store: store} do
    :ok = CookieStore.store(store, @domain, [{"set-cookie", "foo=123"}])
    assert "foo=123" == CookieStore.as_header(store, @domain)
  end


  test "different domain", %{store: store} do
    :ok = CookieStore.store(store, @domain, [{"set-cookie", "foo=123"}])
    assert "" == CookieStore.as_header(store, @domain2)
  end

end
