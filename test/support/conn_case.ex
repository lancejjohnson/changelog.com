defmodule Changelog.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Changelog.Repo
      import Ecto
      import Ecto.Query, only: [from: 2]
      import Plug.Conn, only: [assign: 3]

      defp count(query), do: Repo.count(query)

      import Changelog.Router.Helpers
      import Changelog.Factory
      import Changelog.Plug.Conn

      # The default endpoint for testing
      @endpoint Changelog.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Changelog.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Changelog.Repo, {:shared, self()})
    end

    user = cond do
      tags[:as_admin] -> Changelog.Factory.build(:person, admin: true)
      tags[:as_user] -> Changelog.Factory.build(:person, admin: false)
      tags[:as_inserted_user] -> Changelog.Factory.insert(:person, admin: false)
      true -> nil
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.assign(:current_user, user)

    {:ok, conn: conn, user: user}
  end
end
