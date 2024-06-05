defmodule App.UserEmail do
  import Swoosh.Email

  alias App.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Jobs App", "no-reply@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} = Mailer.deliver(email) do
      {:ok, recipient}
    end
  end

  def magic_link_email(user, magic_link_url) do
    deliver(user.email, "Enlace para ingresar", """
    Hola #{user.email},

    Para ingresar a JobsApp por favor sigue el siguiente enlace:crypto

    #{magic_link_url}
    """)
  end
end
