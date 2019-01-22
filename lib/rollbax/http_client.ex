defmodule Rollbax.HttpClient do
  @moduledoc false

  # This is just a wrapper around `hackney`, useful to make the `RollBax.Client`
  # less coupled to the http client.
  # It enable better testing, and clear the path to support the use of other clients.

  if Mix.env() == :test do
    def client do
      Process.get("http_client_module_for_tests", Rollbax.HttpClient)
    end
  else
    def client, do: :hackney
  end

  # url , @headers, payload, state.hackney_opts

  @callback post(String.t(), String.t(), String.t(), String.t()) :: atom()
end
