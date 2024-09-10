defmodule ExchangeWeb.Live.EctoHelper do
  def enum(values) do
    {:parameterized, Ecto.Enum, Ecto.Enum.init(values: values)}
  end
end
