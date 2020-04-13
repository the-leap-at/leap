defmodule LeapWeb.ComponentsView do
  use LeapWeb, :view

  def markdown_to_html(body) do
    safe =
      body
      |> Earmark.as_html!()
      |> HtmlSanitizeEx.markdown_html()

    raw({:safe, safe})
  end
end
