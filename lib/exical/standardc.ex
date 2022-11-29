defmodule Exical.Standardc do
  @moduledoc """
  [VSTANDARD](https://www.rfc-editor.org/rfc/rfc5545#section-3.6.5) component struct.
  """
  defstruct [
    :dtstart,
    :tzoffsetto,
    :tzoffsetfrom,
    :rrule,
    :comment,
    :rdate,
    :tzname
  ]

  def parse(%Exical.Standardc{
        dtstart: dtstart,
        tzoffsetto: tzoffsetto,
        tzoffsetfrom: tzoffsetfrom,
        rrule: rrule,
        comment: comment,
        rdate: rdate,
        tzname: tzname
      }) do
    %Exical.Standardc{
      dtstart: dtstart,
      tzoffsetto: tzoffsetto,
      tzoffsetfrom: tzoffsetfrom,
      rrule: rrule,
      comment: comment,
      rdate: rdate,
      tzname: tzname
    }
  end
end
