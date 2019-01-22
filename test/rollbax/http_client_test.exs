defmodule Rollbax.HttpClientTest do
  use ExUnit.RollbaxCase

  alias Rollbax.HttpClient

  describe "client/0" do
    test "by default returns the ':hackney' module" do
      assert HttpClient.client() == :hackney
    end
  end
end
