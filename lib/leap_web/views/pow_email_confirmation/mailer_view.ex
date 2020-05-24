defmodule LeapWeb.PowEmailConfirmation.MailerView do
  use LeapWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
