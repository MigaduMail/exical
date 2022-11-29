defmodule Exical.Calendar do
  @moduledoc """
  [VCALENDAR](https://www.rfc-editor.org/rfc/rfc5545#section-3.4) object.
  """
  defstruct prodid: nil,
            version: nil,
            events: [],
            todos: [],
            journals: [],
            freebusy: [],
            timezones: []

  @doc """
  """
  def parse(%Exical.Calendar{
        prodid: prodid,
        version: version,
        events: events,
        todos: todos,
        journals: journals,
        freebusy: freebusy_comps,
        timezones: timezones
      }) do
    %Exical.Calendar{
      prodid: prodid,
      version: version,
      events: events,
      todos: todos,
      journals: journals,
      freebusy: freebusy_comps,
      timezones: timezones
    }
  end
end
