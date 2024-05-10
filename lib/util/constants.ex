defmodule Testcontainers.Constants do
  @moduledoc false

  def library_name, do: :testcontainers
  def library_version, do: "1.7.1"
  def container_label, do: "org.testcontainers"
  def container_lang_label, do: "org.testcontainers.lang"
  def container_lang_value, do: Elixir |> Atom.to_string() |> String.downcase()
  def container_sessionId_label, do: "org.testcontainers.sessionId"
  def container_version_label, do: "org.testcontainers.version"
end
