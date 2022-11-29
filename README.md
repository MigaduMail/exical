# Exical

A simple elixir [icalendar](https://tools.ietf.org/html/rfc5545) parser.
The goal is to parse an icalendar files to proper structs, which can later be used for accessing iCalendar data within application.
This is only the parser with no persistence storage.

## Installation

The package can be installed by adding `exical` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exical, "~> 0.1.0"}
  ]
end
```

## Usage 
```elixir
icalendar_string = "
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//hacksw/handcal//NONSGML v1.0//EN
BEGIN:VEVENT
UID:19970610T172345Z-AF23B2@example.com
DTSTAMP:19970610T172345Z
DTSTART:19970714T170000Z
DTEND:19970715T040000Z
SUMMARY:Bastille Day Party
END:VEVENT
END:VCALENDAR"

Exical.parse_from_ical(icalendar_string)

%Exical.Calendar{
  prodid: %{params: %{}, value: "-//hacksw/handcal//NONSGML v1.0//EN"},
  version: %{params: %{}, value: "2.0"},
  events: [
    %Exical.Event{
      summary: %{params: %{}, value: "Bastille Day Party"},
      dtstamp: %{params: %{}, value: ~U[1997-06-10 17:23:45Z]},
      dtstart: %{params: %{}, value: ~U[1997-07-14 17:00:00Z]},
      dtend: %{params: %{}, value: ~U[1997-07-15 04:00:00Z]},
      rrule: nil,
      exdates: [],
      description: nil,
      location: nil,
      url: nil,
      uid: %{params: %{}, value: "19970610T172345Z-AF23B2@example.com"},
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
    }
  ],
  todos: [],
  journals: [],
  freebusy: [],
  timezones: []
}   
```    
## Documentation

Documentation is available at [Hex](https://hexdocs.pm/exical).
## Note
This a beta version of the library and it will be developed and maintained in the future.
Some test might fail, since it is still in development.
If you find a bug or problem or have some improvements suggestion, please open an issue describing the problem(suggestion) in this repo [exical](https://github.com/MigaduMail/exical).
Currently only supports parsing iCalendar string.
