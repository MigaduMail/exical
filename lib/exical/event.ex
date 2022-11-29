defmodule Exical.Event do
  @moduledoc """
  [VEVENT](https://www.rfc-editor.org/rfc/rfc5545#section-3.6.1) component struct.
  """
  defstruct summary: nil,
            dtstamp: nil,
            dtstart: nil,
            dtend: nil,
            rrule: nil,
            exdates: [],
            description: nil,
            location: nil,
            url: nil,
            uid: nil,
            prodid: nil,
            status: nil,
            categories: nil,
            class: nil,
            comment: nil,
            geo: nil,
            modified: nil,
            organizer: nil,
            sequence: nil,
            attendees: [],
            alarms: []

  def parse(%Exical.Event{
        summary: summary,
        dtstamp: dtstamp,
        dtstart: dtstart,
        dtend: dtend,
        rrule: rrule,
        exdates: exdates,
        description: description,
        location: location,
        url: url,
        uid: uid,
        prodid: prodid,
        status: status,
        categories: categories,
        class: class,
        comment: comment,
        geo: geo,
        modified: modified,
        organizer: organizer,
        sequence: sequence,
        attendees: attendees,
        alarms: alarms
      }) do
    %Exical.Event{
      summary: summary,
      dtstamp: dtstamp,
      dtstart: dtstart,
      dtend: dtend,
      rrule: rrule,
      exdates: exdates,
      description: description,
      location: location,
      url: url,
      uid: uid,
      prodid: prodid,
      status: status,
      categories: categories,
      class: class,
      comment: comment,
      geo: geo,
      modified: modified,
      organizer: organizer,
      sequence: sequence,
      attendees: attendees,
      alarms: alarms
    }
  end
end
