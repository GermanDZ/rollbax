defmodule Rollbax.ClientViaProxyTest do
  use ExUnit.RollbaxCase

  import Mox
  setup [:set_mox_global, :verify_on_exit!]

  alias Rollbax.Client

  setup_all do
    IO.inspect("setting up client")
    Process.put("http_client_module_for_tests", Rollbax.HttpClientMock)

    {:ok, pid} =
      Client.start_link(
        api_endpoint: "http://localhost:4004",
        access_token: "token1",
        environment: "test",
        enabled: true,
        custom: %{qux: "custom"},
        proxy: "http://localhost:14001"
      )

    on_exit(fn ->
      ensure_rollbax_client_down(pid)
    end)
  end

  setup do
    {:ok, _} = RollbarAPI.start(self())
    on_exit(&RollbarAPI.stop/0)
  end

  describe "with proxy" do
    test "Client don't try to contact the api server" do
      IO.inspect("Setting mock")

      Rollbax.HttpClientMock
      |> expect(:post, fn _url, _headers, _payload, _opts ->
        IO.inspect("hjsdfa")
        {:error, "ref"}
      end)

      body = %{"message" => %{"body" => "pass"}}
      occurrence_data = %{"server" => %{"host" => "example.net"}}

      IO.inspect("Ready for test")

      Task.async(fn ->
        :ok =
          Client.emit(
            :warn,
            System.system_time(:second),
            body,
            _custom = %{},
            occurrence_data
          )
      end)
      |> Task.await()

      IO.inspect("after emit")

      # refute_received :api_request
      # assert_receive {:api_request_via_proxy, body}
    end

    test "Client send message to proxy server" do
      body = %{"message" => %{"body" => "pass"}}
      occurrence_data = %{"server" => %{"host" => "example.net"}}

      Rollbax.HttpClientMock
      |> expect(:client, fn -> raise "hellooo222" end)

      :ok =
        Client.emit(
          :warn,
          System.system_time(:second),
          body,
          _custom = %{},
          occurrence_data
        )

      # assert_receive {:api_request_via_proxy, body}
      # json_body = Jason.decode!(body)
      # assert json_body["data"]["server"] == %{"host" => "example.net"}
      # assert json_body["proxied"] == "yes"
    end
  end
end
