defmodule Exical.Freebusy do
  @moduledoc """
  [VFREEBUSY](https://www.rfc-editor.org/rfc/rfc5545#section-3.6.4) component struct.
  """
  defstruct [
    :dtstamp,
    :uid,
    :contact,
    :dtstart,
    :dtend,
    :organizer,
    :url,
    :attendee,
    :comment,
    :freebusy,
    :rstatus
  ]

  def parse(%Exical.Freebusy{
        dtstamp: dtstamp,
        uid: uid,
        contact: contact,
        dtstart: dtstart,
        dtend: dtend,
        organizer: organizer,
        url: url,
        attendee: attendee,
        comment: comment,
        freebusy: freebusy,
        rstatus: rstatus
      }) do
    %Exical.Freebusy{
      dtstamp: dtstamp,
      uid: uid,
      contact: contact,
      dtstart: dtstart,
      dtend: dtend,
      organizer: organizer,
      url: url,
      attendee: attendee,
      comment: comment,
      freebusy: freebusy,
      rstatus: rstatus
    }
  end
end
