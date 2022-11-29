defmodule Exical.Daylightc do
  @moduledoc """
  [VDAYLIGHT](https://www.rfc-editor.org/rfc/rfc5545#section-3.6.5) component.
  """
  alias Exical.Daylightc

  defstruct dtstart: nil,
            tzoffsetto: nil,
            tzoffsetfrom: nil,
            rrule: nil,
            comment: nil,
            rdate: nil,
            tzname: nil

  def parse(%Daylightc{
        dtstart: dtstart,
        tzoffsetto: tzoffsetto,
        tzoffsetfrom: tzoffsetfrom,
        rrule: rrulle,
        comment: comment,
        rdate: rdate,
        tzname: tzname
      }) do
    %Daylightc{
      dtstart: dtstart,
      tzoffsetto: tzoffsetto,
      tzoffsetfrom: tzoffsetfrom,
      rrule: rrulle,
      comment: comment,
      rdate: rdate,
      tzname: tzname
    }
  end
end
