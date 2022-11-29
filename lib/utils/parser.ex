defmodule Exical.Utils.Parser do
  @moduledoc """
  Module responsible for parsing the iCalendar string.

  Main parsing function `from_ical/1` will receive a iCalendar string,
  and should result in [iCalendar object](https://www.rfc-editor.org/rfc/rfc5545#section-3.4) or list of
  [iCalendar components](https://www.rfc-editor.org/rfc/rfc5545#section-3.6).

  ## Examples
      iex> icalendar_string = "BEGIN:VCALENDAR
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

      iex> Exical.Utils.Parser.from_ical(icalendar_string)

      iex> %Exical.Calendar{
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
        alarms: []}
      ],
      todos: [],
      journals: [],
      freebusy: [],
      timezones: []
      }
  """

  alias Exical.Property
  alias Exical.Utils

  @doc """
  Splits a string.
  """
  def qsplit(str) do
    qsplit(str, ",")
  end

  def qsplit(str, sep) do
    String.split(str, sep, trim: true)
  end

  def qsplit(str, _, 0) do
    str
  end

  def qsplit(str, sep, maxsplit) do
    String.split(str, sep, parts: maxsplit, trim: true)
  end

  @doc """
  Parses each line to the `Exical.Property` type for further parsing.
  """
  def parse_line(line) do
    [property_name, values] =
      case String.split(line, ":", parts: 2) do
        [property_name, values] -> [property_name, values]
        [property_name] -> [property_name, ""]
        _ -> ["", ""]
      end

    [property_name, property_params] = get_property_params(property_name)

    Exical.Property.construct_property(property_name, property_params, values)
  end

  @doc """
  This function extracts parameter data from a key in an iCalendar string.
  It should be able to handle multiple parameters per key.

  ## Examples

        iex> Exical.Utils.Parser.get_property_params("DTSTART;TZID=America/Chicago")
        ["DTSTART", %{"TZID" => "America/Chicago"}]
        iex> Exical.Utils.Parser.get_property_params("KEY;LOREM=ipsum;DOLOR=sit")
        ["KEY", %{"LOREM" => "ipsum", "DOLOR" => "sit"}]
  """
  def get_property_params(property_name) do
    [property_name | params] = String.split(property_name, ";", trim: true)

    property_params =
      Enum.reduce(params, %{}, fn param, acc ->
        case String.split(param, "=", parts: 2, trim: true) do
          [key, val] -> Map.merge(acc, %{key => val})
          [key] -> Map.merge(acc, %{key => nil})
          _ -> acc
        end
      end)

    [property_name, property_params]
  end

  @doc """
  Parses the icalendar(ics, ical) text to calendar and property structs.
  Parsing icalendar component is returning a list of icalendar components.
  Each property key will have a map `%{params: %{}, value: ""}` where
  params are additional params for the key and the value is the actual value.

  ## Examples
      ical_event = "
      BEGIN:VEVENT
      UID:19970901T130000Z-123401@example.com
      DTSTAMP:19970901T130000Z
      DTSTART:19970903T163000Z
      DTEND:19970903T190000Z
      SUMMARY:Annual Employee Review
      CATEGORIES:BUSINESS,HUMAN RESOURCES
      END:VEVENT
      "
      Exical.Utils.Parser.from_ical(ical_event)
      [
       %Exical.Event{
       summary: %{params: %{}, value: "Annual Employee Review"},
       dtstamp: %{params: %{}, value: ~U[1997-09-01 13:00:00Z]},
       dtstart: %{params: %{}, value: ~U[1997-09-03 16:30:00Z]},
       dtend: %{params: %{}, value: ~U[1997-09-03 19:00:00Z]},
       rrule: nil,
       exdates: [],
       description: nil,
       location: nil,
       url: nil,
       uid: %{params: %{}, value: "19970901T130000Z-123401@example.com"},
       prodid: nil,
       status: nil,
       categories: %{params: %{}, value: "BUSINESS,HUMAN RESOURCES"},
       class: nil,
       comment: nil,
       geo: nil,
       modified: nil,
       organizer: nil,
       sequence: nil,
       attendees: [],
       alarms: []
      }]

  """
  def from_ical(text) do
    text
    |> String.trim()
    |> Utils.sanitize()
    |> parse_lines()
  end

  def parse_lines(""), do: nil

  def parse_lines(text) do
    text
    |> String.replace(~r"(\r?\n)+[ \t]", "")
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&String.replace(&1, ~S"\n", "\n"))
    |> parse_element(nil, [])
  end

  @doc """
  Parses each element by matching BEGIN and END tags withing the iCalendar string.
  """
  def parse_element([], _current_element, stack), do: Enum.filter(stack, &(!is_nil(&1)))

  def parse_element([head | lines], current_element, stack) do
    case head do
      "BEGIN:VCALENDAR" ->
        parse_element(lines, %Exical.Calendar{}, [])

      "END:VCALENDAR" ->
        current_calendar = Exical.Calendar.parse(current_element)
        # returns the parsed calendar file
        add_component(stack, current_calendar)

      "BEGIN:VEVENT" ->
        parse_element(lines, %Exical.Event{}, List.insert_at(stack, -1, current_element))

      "END:VEVENT" ->
        current_element = Exical.Event.parse(current_element)
        {last_element, stack} = List.pop_at(stack, -1)
        parse_element(lines, last_element, List.insert_at(stack, -1, current_element))

      "BEGIN:VTODO" ->
        parse_element(lines, %Exical.Todo{}, List.insert_at(stack, -1, current_element))

      "END:VTODO" ->
        current_element = Exical.Todo.parse(current_element)
        {last_el, stack} = List.pop_at(stack, -1)
        stack = List.insert_at(stack, -1, current_element)
        parse_element(lines, last_el, stack)

      "BEGIN:VJOURNAL" ->
        parse_element(lines, %Exical.Journal{}, List.insert_at(stack, -1, current_element))

      "END:VJOURNAL" ->
        current_element = Exical.Journal.parse(current_element)
        {last_el, stack} = List.pop_at(stack, -1)
        stack = List.insert_at(stack, -1, current_element)
        parse_element(lines, last_el, stack)

      "BEGIN:VFREEBUSY" ->
        parse_element(lines, %Exical.Freebusy{}, List.insert_at(stack, -1, current_element))

      "END:VFREEBUSY" ->
        freebusy_el = Exical.Freebusy.parse(current_element)
        {last_el, stack} = List.pop_at(stack, -1)
        stack = List.insert_at(stack, -1, freebusy_el)
        parse_element(lines, last_el, stack)

      "BEGIN:VTIMEZONE" ->
        parse_element(lines, %Exical.Timezone{}, List.insert_at(stack, -1, current_element))

      "BEGIN:STANDARD" ->
        parse_element(lines, %Exical.Standardc{}, List.insert_at(stack, -1, current_element))

      "END:STANDARD" ->
        standardc = Exical.Standardc.parse(current_element)
        {last_el, stack} = List.pop_at(stack, -1)
        std = Map.get(last_el, :standardc)
        standardc = List.insert_at(std, -1, standardc)
        last_el = %{last_el | standardc: standardc}
        parse_element(lines, last_el, stack)

      "BEGIN:DAYLIGHT" ->
        parse_element(lines, %Exical.Daylightc{}, List.insert_at(stack, -1, current_element))

      "END:DAYLIGHT" ->
        daylightc = Exical.Daylightc.parse(current_element)
        {last_element, stack} = List.pop_at(stack, -1)
        daylight = Map.get(last_element, :daylightc)
        daylights = List.insert_at(daylight, -1, daylightc)
        last_element = %{last_element | daylightc: daylights}
        parse_element(lines, last_element, stack)

      "END:VTIMEZONE" ->
        current_element = Exical.Timezone.parse(current_element)
        {last_el, stack} = List.pop_at(stack, -1)
        stack = List.insert_at(stack, -1, current_element)
        parse_element(lines, last_el, stack)

      "BEGIN:VALARM" ->
        parse_element(lines, %Exical.Alarm{}, List.insert_at(stack, -1, current_element))

      "END:VALARM" ->
        current_alarm = Exical.Alarm.parse(current_element)
        {last_element, stack} = List.pop_at(stack, -1)
        alarms = Map.get(last_element, :alarms)
        alarms = List.insert_at(alarms, -1, current_alarm)
        last_element = %{last_element | alarms: alarms}
        parse_element(lines, last_element, stack)

      head ->
        pline = parse_line(head)
        parse_element(lines, merge_params_in_current_element(current_element, pline), stack)
    end
  end

  def merge_params_in_current_element(current_element, %Property{key: key} = property) do
    Map.has_key?(current_element, key)
    |> maybe_update_current_element(current_element, property)
  end

  @doc """
  Merges the current element struct with the parsed property.
  In case property is not part of the iCalendar component, it won't be merged.
  """
  def maybe_update_current_element(false, current_element, _property), do: current_element

  def maybe_update_current_element(true, current_element, %Property{key: key} = property) do
    key_values = parse_property_values(property)
    %{current_element | key => key_values}
  end

  @doc """
  Parsed property consists of value and additional params, so
  it will return the map of value and params.
  You can always pattern match on maps easily, to extract params or values, or both.
  See `Exical.Property` for details about parsing string values to elixir values


  ## Examples

      Exical.Utils.Parser.parse_property_values(%Exical.Property{key: :dtstart, params: %{"VALUE" => "DATE"}, value: "19970903T163000Z"}
      %{value: ~U[1997-09-01 13:00:00Z], params: %{}}

  """
  def parse_property_values(%Exical.Property{params: property_params} = property) do
    value = Exical.Property.parse_prop(property)
    %{value: value, params: property_params}
  end

  @doc """
  When parsing of each iCalendar component in iCalendar object is done, all components are added to the iCalendar object.
  """
  def add_component([], %Exical.Calendar{} = calendar), do: calendar

  def add_component(
        [%Exical.Todo{} = todo | rest],
        %Exical.Calendar{todos: todos} = calendar
      ) do
    todos = List.insert_at(todos, -1, todo)
    calendar = %{calendar | todos: todos}
    add_component(rest, calendar)
  end

  def add_component(
        [%Exical.Event{} = event | rest],
        %Exical.Calendar{events: events} = calendar
      ) do
    events = List.insert_at(events, -1, event)
    calendar = %{calendar | events: events}
    add_component(rest, calendar)
  end

  def add_component(
        [%Exical.Journal{} = journal | rest],
        %Exical.Calendar{journals: journals} = calendar
      ) do
    journals = List.insert_at(journals, -1, journal)
    calendar = %{calendar | journals: journals}
    add_component(rest, calendar)
  end

  def add_component(
        [%Exical.Freebusy{} = freebusy | rest],
        %Exical.Calendar{freebusy: freebusy_comps} = calendar
      ) do
    calendar = %{calendar | freebusy: [freebusy | freebusy_comps]}
    add_component(rest, calendar)
  end

  def add_component(
        [%Exical.Timezone{} = timezone | rest],
        %Exical.Calendar{timezones: timezones} = calendar
      ) do
    calendar = %{calendar | timezones: [timezone | timezones]}
    add_component(rest, calendar)
  end
end
