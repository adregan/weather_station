defmodule WeatherStationWeb.Plugs.SessionId do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    case get_session(conn, :session_id) do
      nil -> put_session(conn, :session_id, gen_session_id())
      _ -> conn
    end
  end

  def gen_session_id do
    Ecto.UUID.generate()
  end
end
