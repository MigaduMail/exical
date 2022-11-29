defmodule Exical.Utils do
  @moduledoc """
  Helper functions for parsing.
  """
  def to_date(date_string, _type) when is_nil(date_string), do: nil

  def to_date(date_string, %{"TZID" => timezone}) do
    # Microsoft Outlook calendar .ICS files report times in Greenwich Standard Time (UTC +0)
    # so just convert this to UTC
    timezone =
      if Regex.match?(~r/\//, timezone) do
        timezone
      else
        Timex.Timezone.Utils.to_olson(timezone)
      end

    date_string =
      case String.last(date_string) do
        "Z" -> date_string
        _ -> date_string <> "Z"
      end

    Timex.parse!(date_string <> timezone, "{YYYY}{0M}{0D}T{h24}{m}{s}Z{Zname}")
  end

  def to_date(date_string, %{"VALUE" => "DATE"}) do
    to_date(date_string <> "T000000Z")
  end

  def to_date(date_string, %{}) do
    to_date(date_string, %{"TZID" => "Etc/UTC"})
  end

  def to_date(date_string) do
    to_date(date_string, %{"TZID" => "Etc/UTC"})
  end

  def to_geo(geo) when is_nil(geo) do
    nil
  end

  def to_geo(geo) do
    geo
    |> desanitized()
    |> String.split(";")
    |> Enum.map(fn x -> Float.parse(x) end)
    |> Enum.map(fn {x, _} -> x end)
    |> List.to_tuple()
  end

  @doc ~S"""
  This function should strip any sanitization that has been applied to content
  within an iCal string.

  iex> ICalendar.Util.Deserialize.desanitized(~s(lorem\\, ipsum))
  "lorem, ipsum"
  """
  def desanitized(string) do
    string
    |> String.replace(~s(\\), "")
  end

  def sanitize(str) do
    Regex.replace(~r/(\r?\n)+[ \t]/, str, "")
  end
end
