defmodule LeapWeb.PowResetPassword.MailerView do
  use LeapWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
