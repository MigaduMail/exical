defmodule Exical.Alarm do
  @moduledoc """
  [VALARM](https://www.rfc-editor.org/rfc/rfc5545#section-3.6.6) component.
  """
  defstruct uid: nil,
            action: nil,
            trigger: nil,
            duration: nil,
            repeat: nil,
            attach: nil,
            description: nil,
            summary: nil,
            attendee: nil,
            acknowledged: nil

  def parse(%Exical.Alarm{
        uid: uid,
        action: action,
        trigger: trigger,
        duration: duration,
        repeat: repeat,
        attach: attach,
        description: description,
        summary: summary,
        attendee: attendee,
        acknowledged: acknowledged
      }) do
    %Exical.Alarm{
      uid: uid,
      action: action,
      trigger: trigger,
      duration: duration,
      repeat: repeat,
      attach: attach,
      description: description,
      summary: summary,
      attendee: attendee,
      acknowledged: acknowledged
    }
  end
end
