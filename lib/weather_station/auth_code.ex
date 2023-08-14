defmodule WeatherStation.AuthCode do
  @lower ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
  @upper @lower |> Enum.map(&String.upcase/1)
  @alpha @upper ++ @lower
  @max length(@alpha)

  def generate(len) when is_number(len) do
    for _ <- 1..len, into: "" do
      # :rand.uniform returns in the range of 1-N. To access 0, subtract 1.
      Enum.at(@alpha, :rand.uniform(@max) - 1)
    end
  end
end
