defmodule App.UserEmail do
  import Swoosh.Email

  alias App.Mailer

  @from {"Jobs App", "no-reply@example.com"}

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from(@from)
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} = Mailer.deliver(email) do
      {:ok, recipient}
    end
  end

  def magic_link_email(user, magic_link_url) do
    subject = "Enlace para ingresar"
    body_email = email_body(user, magic_link_url)

    if System.get_env("RESEND_API_KEY") do
      send_email_using_resend(%{user: user, subject: subject, body: body_email})
    else
      deliver(user.email, subject, body_email)
    end
  end

  def email_body(user, magic_link_url) do
    """
    Hola #{user.email},

    Para ingresar a JobsApp por favor sigue el siguiente enlace:crypto

    #{magic_link_url}
    """
  end

  defp send_email_using_resend(%{user: user, subject: subject, body: body}) do
    client = Resend.client(api_key: System.get_env("RESEND_API_KEY"))

    Resend.Emails.send(client, %{
      from: "Acme <onboarding@resend.dev>",
      to: [user.email],
      subject: subject,
      text: body
    })
  end
end
