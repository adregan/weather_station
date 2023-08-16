defmodule WeatherStation.ConnectionTest do
  use ExUnit.Case
  alias WeatherStation.Connection

  @token %WeatherStation.Auth.Token{
    user_id: Faker.UUID.v4(),
    token: Faker.UUID.v4(),
    location: :outdoor,
    service: :tempest
  }

  test "new with a nil token returns a disconnected connection" do
    assert Connection.new(nil) == %Connection{status: :disconnected}
  end

  test "new with a token returns a pending connection" do
    assert Connection.new(@token) == %Connection{status: :pending, token: @token}
  end

  test "connect adds last_connected time and updates status" do
    connection =
      Connection.new(@token)
      |> Connection.connect()

    assert connection.status == :connected
    assert connection.last_connected != nil
  end

  test "heart_beat updates the last_connected time" do
    connection =
      Connection.new(@token)
      |> Connection.connect()

    assert Connection.heart_beat(connection).last_connected > connection.last_connected
  end

  test "disconnect returns a disconnected Connection" do
    connection =
      Connection.new(@token)
      |> Connection.connect()

    assert Connection.disconnect(connection) == %Connection{
             status: :disconnected,
             token: nil,
             last_connected: nil
           }
  end
end
