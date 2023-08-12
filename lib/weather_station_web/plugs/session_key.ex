defmodule WeatherStationWeb.Plugs.SessionKey do
  alias WeatherStation.Accounts
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    case get_session(conn, :session_key) do
      nil ->
        start_new_session(conn)

      existing_key ->
        validate_or_start(conn, existing_key)
    end
  end

  def start_new_session(conn) do
    {:ok, user} = Accounts.create_user()
    put_session(conn, :session_key, user.session_key)
  end

  def validate_or_start(conn, session_key) do
    case Accounts.get_user_by_session_key(session_key) do
      nil -> start_new_session(conn)
      _ -> conn
    end
  end
end
