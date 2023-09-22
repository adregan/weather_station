defmodule WeatherStation.OauthClient do
  @doc """
  Produces the authorization link used to initiate OAuth
  """
  @type redirect_uri :: String.t
  @callback authorize_link(redirect_uri) :: String.t

  @doc """
  Fetches the access_token using the given authorization code, returned in a
  result tuple.
  """
  @type code :: String.t
  @type token :: String.t
  @type reason :: String.t
  @callback access_token(code) :: {:ok, token} | {:error, reason}

  @doc """
  Returns the atom with the name of the service.
  """
  @callback name :: atom
end
