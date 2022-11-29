defmodule Exical.Property do
  @moduledoc """
  Each property in an iCalendar object can have multiple params and values.
  This module is responsible for extracting and parsing values and additional params for property in ICalendar string.

  ## Examples
  ICalendar line after parsing to property should have struct like this:
      ical_line = "DTSTAMP:20070514T103211Z"
      %Property{key: :dtstamp, params: %{}, values: "20070514T103211Z"}

  More transformation of the property is done when parsing a whole text file.
  See `Exical.Utils.Parser`
  """
  alias Exical.Property

  @type t :: %__MODULE__{
          key: atom(),
          params: map(),
          values: any()
        }

  defstruct key: nil, params: %{}, values: nil

  def construct_property(key, params, values) do
    key = atomize_key(key)

    params =
      key
      |> extract_additional_params_in_map(params, values)
      |> Map.merge(params)

    %Property{
      key: key,
      params: params,
      values: values
    }
  end

  @doc """
  Parses values for each key in property based on provided params.
  """
  def parse_prop(%Property{key: :trigger, params: params, values: values}) do
    Exical.Utils.to_date(values, params)
  end

  def parse_prop(%Property{key: :rrule, params: params, values: _val}) do
    params
  end

  def parse_prop(%Property{key: :geo, params: params, values: _values}) do
    Exical.Utils.to_geo(params)
  end

  def parse_prop(%Property{key: :due, params: params, values: values}) do
    Exical.Utils.to_date(values, params)
  end

  def parse_prop(%Property{key: :dtstamp, params: params, values: values}) do
    Exical.Utils.to_date(values, params)
  end

  def parse_prop(%Property{key: :dtend, params: params, values: values}) do
    Exical.Utils.to_date(values, params)
  end

  def parse_prop(%Property{key: :completed, params: params, values: values}) do
    Exical.Utils.to_date(values, params)
  end

  def parse_prop(%Property{key: :dtstart, params: params, values: values}) do
    Exical.Utils.to_date(values, params)
  end

  def parse_prop(%Property{key: key, params: %{}, values: nil}) when not is_nil(key), do: nil

  def parse_prop(%Property{key: key, params: %{}, values: values}) when not is_nil(key),
    do: values

  def atomize_key(key) when is_atom(key), do: key

  def atomize_key(key) when is_binary(key) do
    key
    |> String.downcase()
    |> String.to_atom()
  end

  @doc """
  Extract all the params keys and values in the property as a separate map.
  """
  def extract_additional_params_in_map(prop_key, params, values) do
    if String.contains?(values, ";") do
      Enum.map(String.split(values, ";"), fn val ->
        if String.contains?(val, "=") do
          [key, val] = String.split(val, "=")
          key = atomize_key(key)

          val =
            %Property{key: key, params: %{}, values: val}
            |> parse_prop()

          %{key => val}
        else
          val =
            %Property{key: prop_key, params: params, values: values}
            |> parse_prop()

          %{prop_key => val}
        end
      end)
      |> Enum.reduce(%{}, &Enum.into/2)
    else
      params
    end
  end
end
