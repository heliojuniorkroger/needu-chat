defmodule NeeduChatTest do
  use ExUnit.Case
  doctest NeeduChat

  test "greets the world" do
    assert NeeduChat.hello() == :world
  end
end
