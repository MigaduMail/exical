defmodule Exical.Timezone do
  @moduledoc """
  [VTIMEZONE](https://www.rfc-editor.org/rfc/rfc5545#section-3.6.5) component.
  """
  defstruct tzid: nil,
            last_modified: nil,
            tzurl: nil,
            standardc: [],
            daylightc: []

  def parse(%__MODULE__{
        tzid: tzid,
        last_modified: last_modified,
        tzurl: tzurl,
        standardc: standardc,
        daylightc: daylightc
      }) do
    %__MODULE__{
      tzid: tzid,
      last_modified: last_modified,
      tzurl: tzurl,
      standardc: standardc,
      daylightc: daylightc
    }
  end
end
