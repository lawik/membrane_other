defmodule MembraneOtherTest do
  use ExUnit.Case

  alias MembraneOther.Pipeline

  test "greets the world" do
    infile = "/tmp/myinput.txt"
    text = "I enjoy text...\nThis is great."
    File.write!(infile, text)
    outfile = "/tmp/myoutput.txt"
    {:ok, pid} = Pipeline.start_link(infile: infile, outfile: outfile, completion_pid: self())
    Pipeline.play(pid)

    receive do
      :done ->
        assert true
    after
      5000 ->
        refute true
    end

    receive do
      :shutdown ->
        assert true
    after
      5000 ->
        refute true
    end

    assert String.upcase(text) == File.read!(outfile)
  end
end
