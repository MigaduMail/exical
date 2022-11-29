defmodule Exical do
  @moduledoc """
  A simple elixir [iCalendar](https://tools.ietf.org/html/rfc5545) parsing library.
  The goal is to parse an icalendar files to proper structs, which can later be used for accessing iCalendar data.
  This is only the parser with no persistence storage.

  Currenly only supported to parse iCalendar string.

  Supported [iCalendar components](https://www.rfc-editor.org/rfc/rfc5545#section-3.6):

  * VCALENDAR `Exical.Calendar`
  * VALARM `Exical.Alarm`
  * VTIMEZONE `Exical.Timezone`
  * VEVENT `Exical.Event`
  * VFREEBUSY `Exical.Freebusy`
  * VJOURNAL `Exical.Journal`
  * VSTANDARD `Exical.Standardc`
  * VDAYLIGHT `Exical.Daylightc`
  * VTODO `Exical.Todo`

  Please refer to parsing module `Exical.Utils.Parser` docs for further information about the parser.
  """

  defdelegate parse_from_ical(full_text), to: Exical.Utils.Parser, as: :from_ical
end
