defmodule Exicalend.ParserTest do
  use ExUnit.Case
  doctest Exicalend

  test "q_split" do
    assert Exicalend.Parser.qsplit("aaaa,bbbb") == ["aaaa", "bbbb"]
  end

  describe "ICalendar.from_ics/1" do
    test "from_ical" do
      text =
        "BEGIN:VEVENT\nCREATED:20081114T072804Z\nUID:D449CA84-00A3-4E55-83E1-34B58268853B\nDTEND:20070220T180000\nRRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20070619T225959\nTRANSP:OPAQUE\nSUMMARY:Esb mellon\n phone conf\nDTSTART:20070220T170000\nDzTSTAMP:20070221T095412Z\nSEQUENCE:0\nEND:VEVENT"

      assert Exicalend.Parser.from_ical(text) ==
               [
                 %Exicalend.Event{
                   attendees: [],
                   categories: nil,
                   class: nil,
                   comment: nil,
                   description: nil,
                   dtend: ~U[2007-02-20 18:00:00Z],
                   dtstart: ~U[2007-02-20 17:00:00Z],
                   exdates: [],
                   geo: nil,
                   location: nil,
                   modified: nil,
                   organizer: nil,
                   prodid: nil,
                   rrule: %{freq: "WEEKLY", interval: 1, until: ~U[2007-06-19 22:59:59Z]},
                   sequence: "0",
                   status: nil,
                   summary: "Esb mellonphone conf",
                   uid: "D449CA84-00A3-4E55-83E1-34B58268853B",
                   url: nil
                 }
               ]
    end

    test "Single Event" do
      ics = """
      BEGIN:VEVENT
      DESCRIPTION:Escape from the world. Stare at some water.
      COMMENT:Don't forget to take something to eat !
      SUMMARY:Going fishing
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      LOCATION:123 Fun Street\\, Toronto ON\\, Canada
      STATUS:TENTATIVE
      CATEGORIES:Fishing,Nature
      CLASS:PRIVATE
      GEO:43.6978819;-79.3810277
      END:VEVENT
      """

      [event] = Exicalend.Parser.from_ical(ics)

      assert event == %Exicalend.Event{
               dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 0}}),
               dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 0}}),
               summary: "Going fishing",
               description: "Escape from the world. Stare at some water.",
               location: "123 Fun Street, Toronto ON, Canada",
               status: "tentative",
               categories: ["Fishing", "Nature"],
               comment: "Don't forget to take something to eat !",
               class: "private",
               geo: {43.6978819, -79.3810277}
             }
    end

    test "with Timezone" do
      ics = """
      BEGIN:VEVENT
      DTEND;TZID=America/Chicago:22221224T084500
      DTSTART;TZID=America/Chicago:22221224T083000
      END:VEVENT
      """

      [event] = ICalendar.from_ics(ics)

      [event] = Exicalend.Parser.from_ical(ics)
      assert event.dtstart.time_zone == "America/Chicago"
      assert event.dtend.time_zone == "America/Chicago"
    end

    test "with CR+LF line endings" do
      ics = """
      BEGIN:VEVENT
      DESCRIPTION:CR+LF line endings\r\nSUMMARY:Going fishing\r
      DTEND:20151224T084500Z\r\nDTSTART:20151224T083000Z\r
      END:VEVENT
      """

      [event] = Exicalend.Parser.from_ical(ics)
      assert event.description == "CR+LF line endings"
    end

    test "with URL" do
      ics = """
      BEGIN:VEVENT
      DESCRIPTION:Escape from the world. Stare at some water.
      COMMENT:Don't forget to take something to eat !
      URL:http://google.com
      SUMMARY:Going fishing
      DTEND:20151224T084500Z
      DTSTART:20151224T083000Z
      LOCATION:123 Fun Street\\, Toronto ON\\, Canada
      STATUS:TENTATIVE
      CATEGORIES:Fishing,Nature
      CLASS:PRIVATE
      GEO:43.6978819;-79.3810277
      END:VEVENT
      """

      [event] = Exicalend.Parser.from_ical(ics)
      assert event.url == "http://google.com"
    end
  end

  test "parse_line UID" do
    line = "UID:D449CA84-00A3-4E55-83E1-34B58268853B"
    assert Exicalend.Parser.parse_line(line) == %{uid: "D449CA84-00A3-4E55-83E1-34B58268853B"}
  end

  test "parse_line RRULE" do
    line = "RRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20070619T225959"

    assert Exicalend.Parser.parse_line(line) == %{
             rrule: %{freq: "WEEKLY", interval: 1, until: ~U[2007-06-19 22:59:59Z]}
           }
  end

  test "from ical with valarm" do
    ics = """
    BEGIN:VEVENT
    DESCRIPTION:Meeting for important tasks
    SUMMARY:Meeting
    DTEND:20151224T084500Z
    DTSTART:20151224T083000Z
    BEGIN:VALARM
    UID:ACBAGADA
    TRIGGER:-PT15M
    DESCRIPTION:Event reminder
    ACTION:DISPLAY
    END:VALARM
    BEGIN:VALARM
    UID:ACBAGADA2
    TRIGGER;VALUE=DATE-TIME:20150101T050000Z
    DESCRIPTION:Second event reminder
    ACTION:DISPLAY
    END:VALARM
    END:VEVENT
    """

    [event] = Exicalend.Parser.from_ical(ics)

    assert event.alarms == [
             %Exicalend.Alarm{
               acknowledged: nil,
               action: "DISPLAY",
               attach: nil,
               attendee: nil,
               description: "Event reminder",
               duration: nil,
               repeat: nil,
               summary: nil,
               trigger: "-PT15M",
               uid: "ACBAGADA"
             },
             %Exicalend.Alarm{
               acknowledged: nil,
               action: "DISPLAY",
               attach: nil,
               attendee: nil,
               description: "Second event reminder",
               duration: nil,
               repeat: nil,
               summary: nil,
               trigger: "20150101T050000Z",
               uid: "ACBAGADA2"
             }
           ]
  end

  test "Single real event" do
    ics = """
    BEGIN:VCALENDAR\nPRODID:-//alps//EN
    VERSION:2.0
    BEGIN:VEVENT\nDTEND:20220316T140000Z
    DTSTAMP;TZID=UTC:20220315T075326\nDTSTART:20220316T000000Z
    SUMMARY:none\nUID:4a39ed9c-1c27-471b-9cce-d4e724854091\nEND:VEVENT
    END:VCALENDAR\n
    """

    cal = Exicalend.Parser.from_ical(ics)

    assert cal == %Exicalend.Calendar{
             events: [
               %Exicalend.Event{
                 alarms: [],
                 attendees: [],
                 categories: nil,
                 class: nil,
                 comment: nil,
                 description: nil,
                 dtend: ~U[2022-03-16 14:00:00Z],
                 dtstart: ~U[2022-03-16 00:00:00Z],
                 dtstamp: ~U[2022-03-15 07:53:26Z],
                 exdates: [],
                 geo: nil,
                 location: nil,
                 modified: nil,
                 organizer: nil,
                 prodid: nil,
                 rrule: nil,
                 sequence: nil,
                 status: nil,
                 summary: "none",
                 uid: "4a39ed9c-1c27-471b-9cce-d4e724854091",
                 url: nil
               }
             ],
             prodid: "-//alps//EN",
             version: "2.0"
           }
  end

  test "Single VTODO component" do
    vtodo_ics = """
    BEGIN:VTODO
    UID:20070514T103211Z-123404@example.com
    DTSTAMP:20070514T103211Z
    DTSTART:20070514T110000Z
    DUE:20070709T130000Z
    COMPLETED:20070707T100000Z
    SUMMARY:Submit Revised Internet-Draft
    PRIORITY:1
    STATUS:NEEDS-ACTION
    DESCRIPTION:Describe data as: MAPS, LISTS, TUPLES\n
      or something meaningful.
    END:VTODO
    """

    [todo] = Exicalend.Parser.from_ical(vtodo_ics)

    assert todo == %Exicalend.Todo{
             alarms: [],
             dtstamp: ~U[2007-05-14 10:32:11Z],
             dtstart: ~U[2007-05-14 11:00:00Z],
             uid: "20070514T103211Z-123404@example.com",
             class: nil,
             completed: ~U[2007-07-07 10:00:00Z],
             created: nil,
             description: "Describe data as: MAPS, LISTS, TUPLES or something meaningful",
             geo: nil,
             last_mod: nil,
             location: nil,
             organizer: nil,
             percent: nil,
             priority: "1",
             recurid: nil,
             seq: nil,
             status: "needs-action",
             summary: "Submit Revised Internet-Draft",
             url: nil,
             rrule: nil,
             due: ~U[2007-07-09 13:00:00Z],
             duration: nil,
             attendee: nil,
             attach: nil,
             categories: nil,
             comments: nil,
             exdates: [],
             contacts: nil,
             rstatuses: nil,
             rdate: nil,
             resources: [],
             related: nil
           }
  end

  test "TODO component in iCalendar object" do
    ics = """
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//alps//EN
    BEGIN:VTODO
    UID:20070514T103211Z-123404@example.com
    DTSTAMP:20070514T103211Z
    DTSTART:20070514T110000Z
    DUE:20070709T130000Z
    COMPLETED:20070707T100000Z
    SUMMARY:Submit Revised Internet-Draft
    PRIORITY:1
    STATUS:NEEDS-ACTION
    END:VTODO
    END:VCALENDAR
    """

    icalendar = Exicalend.Parser.from_ical(ics)
    refute Enum.empty?(icalendar.todos)

    assert icalendar.todos == [
             %Exicalend.Todo{
               alarms: [],
               dtstamp: ~U[2007-05-14 10:32:11Z],
               dtstart: ~U[2007-05-14 11:00:00Z],
               uid: "20070514T103211Z-123404@example.com",
               class: nil,
               completed: ~U[2007-07-07 10:00:00Z],
               created: nil,
               description: nil,
               geo: nil,
               last_mod: nil,
               location: nil,
               organizer: nil,
               percent: nil,
               priority: "1",
               recurid: nil,
               seq: nil,
               status: "needs-action",
               summary: "Submit Revised Internet-Draft",
               url: nil,
               rrule: nil,
               due: ~U[2007-07-09 13:00:00Z],
               duration: nil,
               attendee: nil,
               attach: nil,
               categories: nil,
               comments: nil,
               exdates: [],
               contacts: nil,
               rstatuses: nil,
               rdate: nil,
               resources: [],
               related: nil
             }
           ]
  end

  # This test is failing due to
  # issue with parsing params in property
  test "Single VJOURNAL component" do
    journal_ics = """
    BEGIN:VJOURNAL
    UID:19970901T130000Z-123405@example.com
    DTSTAMP:19970901T130000Z
    DTSTART;VALUE=DATE:19970317
    SUMMARY:Staff meeting minutes
    DESCRIPTION:1. Staff meeting: Participants include Joe\n,
    Lisa\n, and Bob. Aurora project plans were reviewed.
    There is currently no budget reserves for this project.
    Lisa will escalate to management. Next meeting on Tuesday.\n
    2. Telephone Conference: ABC Corp. sales representative
    called to discuss new printer. Promised to get us a demo by
    Friday.\n3. Henry Miller (Handsoff Insurance): Car was
    totaled by tree. Is looking into a loaner car. 555-2323
    (tel).
    END:VJOURNAL
    """

    [journal] = Exicalend.Parser.from_ical(journal_ics)

    assert journal == %Exicalend.Journal{
             uid: "19970901T130000Z-123405@example.com",
             dtstamp: ~U[1997-09-01 13:00:00Z],
             dtstart: ~U[1997-03-17 00:00:00Z],
             summary: "Staff meeting minutes",
             description: "1. Staff meeting: Participants include Joe,
        Lisa, and Bob. Aurora project plans were reviewed.
        There is currently no budget reserves for this project.
        Lisa will escalate to management. Next meeting on Tuesday.\n
        2. Telephone Conference: ABC Corp. sales representative
        called to discuss new printer. Promised to get us a demo by
        Friday.\n3. Henry Miller (Handsoff Insurance): Car was
        totaled by tree. Is looking into a loaner car. 555-2323
        (tel)."
           }
  end

  describe "VFREEBUSY COMPONENT" do
    test "Single VFREEBUSY request component" do
      freebusy_ics = ~S"""
      BEGIN:VFREEBUSY
      UID:19970901T082949Z-FA43EF@example.com
      ORGANIZER:mailto:jane_doe@example.com
      ATTENDEE:mailto:john_public@example.com
      DTSTART:19971015T050000Z
      DTEND:19971016T050000Z
      DTSTAMP:19970901T083000Z
      END:VFREEBUSY
      """

      [fb_comp] = Exicalend.Parser.from_ical(freebusy_ics)
      # The current problem is parsing
      # params like 'mailto'
      # maybe it should be in form of keyword list
      # or map like %{mailto: john_public@example.com}

      assert fb_comp = %Exicalend.Freebusy{
               attendee: "mailto:john_public@example.com",
               comment: nil,
               contact: nil,
               dtend: ~U[1997-10-16 05:00:00Z],
               dtstamp: ~U[1997-09-01 08:30:00Z],
               dtstart: ~U[1997-10-15 05:00:00Z],
               freebusy: nil,
               organizer: "mailto:jane_doe@example.com",
               rstatus: nil,
               uid: "19970901T082949Z-FA43EF@example.com",
               url: nil
             }
    end

    test "Single VFREEBUSY response component" do
      ics = ~S"""
      BEGIN:VFREEBUSY
      UID:19970901T095957Z-76A912@example.com
      ORGANIZER:mailto:jane_doe@example.com
      ATTENDEE:mailto:john_public@example.com
      DTSTAMP:19970901T100000Z
      FREEBUSY:19971015T050000Z/PT8H30M,
       19971015T160000Z/PT5H30M,19971015T223000Z/PT6H30M
      URL:http://example.com/pub/busy/jpublic-01.ifb
      COMMENT:This iCalendar file contains busy time information for
        the next three months.
      END:VFREEBUSY
      """

      [fb_comp] = Exicalend.Parser.from_ical(ics)

      assert fb_comp == %Exicalend.Freebusy{
               attendee: "mailto:john_public@example.com",
               comment:
                 "This iCalendar file contains busy time information for the next three months.",
               contact: nil,
               dtend: nil,
               dtstamp: ~U[1997-09-01 10:00:00Z],
               dtstart: nil,
               freebusy:
                 "19971015T050000Z/PT8H30M,19971015T160000Z/PT5H30M,19971015T223000Z/PT6H30M",
               organizer: "mailto:jane_doe@example.com",
               rstatus: nil,
               uid: "19970901T095957Z-76A912@example.com",
               url: "http://example.com/pub/busy/jpublic-01.ifb"
             }
    end
  end

  test "Freebusy component in iCalendar object" do
    ical = ~S"""
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    PRODID:-//Apple Inc.//iOS 12.4.1//EN
    VERSION:2.0
    BEGIN:VFREEBUSY
    UID:19970901T095957Z-76A912@example.com
    ORGANIZER:mailto:jane_doe@example.com
    ATTENDEE:mailto:john_public@example.com
    DTSTAMP:19970901T100000Z
    FREEBUSY:19971015T050000Z/PT8H30M,
     19971015T160000Z/PT5H30M,19971015T223000Z/PT6H30M
    URL:http://example.com/pub/busy/jpublic-01.ifb
    COMMENT:This iCalendar file contains busy time information for
      the next three months.
    END:VFREEBUSY
    BEGIN:VEVENT
    CREATED:20200506T132336Z
    DTEND;TZID=Europe/Paris:20200506T180000
    DTSTAMP:20200506T132337Z
    DTSTART;TZID=Europe/Paris:20200506T170000
    LAST-MODIFIED:20200506T132336Z
    LOCATION:Blumenweg 79\nGermany
    SEQUENCE:0
    SUMMARY:Dinner
    TRANSP:OPAQUE
    UID:CBD5D471-B2CB-45D0-9E71-362D379B73F6
    URL;VALUE=URI:
    X-APPLE-STRUCTURED-LOCATION;VALUE=URI;X-ADDRESS=Blumenweg 79\\nGermany;
     X-APPLE-ABUID=Hans Huber’s Home;X-APPLE-REFERENCEFRAME=1;X-T
     ITLE=Blumenweg 79\\nGermany:geo:49.160923,8.611724
    BEGIN:VALARM
    ACTION:NONE
    TRIGGER;VALUE=DATE-TIME:19760401T005545Z
    END:VALARM
    END:VEVENT
    END:VCALENDAR
    """

    ical = Exicalend.Parser.from_ical(ical)

    refute Enum.empty?(ical.freebusy)

    assert ical.freebusy == [
             %Exicalend.Freebusy{
               attendee: "mailto:john_public@example.com",
               comment:
                 "This iCalendar file contains busy time information for the next three months.",
               contact: nil,
               dtend: nil,
               dtstamp: ~U[1997-09-01 10:00:00Z],
               dtstart: nil,
               freebusy:
                 "19971015T050000Z/PT8H30M,19971015T160000Z/PT5H30M,19971015T223000Z/PT6H30M",
               organizer: "mailto:jane_doe@example.com",
               rstatus: nil,
               uid: "19970901T095957Z-76A912@example.com",
               url: "http://example.com/pub/busy/jpublic-01.ifb"
             }
           ]
  end
end
