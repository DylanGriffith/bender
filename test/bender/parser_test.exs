defmodule Bender.ParserTest do
  use ExUnit.Case

  test "#try_parse parses out echo command" do
    assert Bender.Parser.try_parse("bender echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse does not work unless the command prefix starts the string" do
    assert Bender.Parser.try_parse("@bender echo hello world") ==
             nil
  end

  test "#try_parse supports using bender:" do
    assert Bender.Parser.try_parse("bender: echo hello world") ==
             {:command, "echo", "hello world"}
  end

  test "#try_parse supports using uppercase" do
    assert Bender.Parser.try_parse("Bender echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports commands with hyphens" do
    assert Bender.Parser.try_parse("Bender foo-bar hello world") ==
             {:command, "foo-bar", "hello world"}
  end

  test "#try_parse supports custom command_prefix" do
    assert Bender.Parser.try_parse("foobar echo hello world", "foobar") ==
             {:command, "echo", "hello world"}
  end

  test "#try_parse supports empty message after command" do
    assert Bender.Parser.try_parse("bender ping") == {:command, "ping", ""}
  end

  test "#try_parse returns nil for invalid command" do
    assert Bender.Parser.try_parse("foo bar hello world") == nil
  end
end
