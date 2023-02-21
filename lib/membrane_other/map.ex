defmodule MembraneOther.Map do
  use Membrane.Filter

  def_options(
    fun: [
      spec: :any,
      default: nil,
      description: "Function callback for mapping incoming data to outgoing data."
    ]
  )

  def_input_pad(:input,
    demand_unit: :buffers,
    caps: :any
  )

  def_output_pad(:output,
    availability: :always,
    mode: :pull,
    caps: :any
  )

  @impl true
  def handle_init(%__MODULE{fun: fun}) do
    {:ok, %{fun: fun}}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {{:ok, demand: :input}, state}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _context, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, %Membrane.Buffer{} = buffer, _context, state) do
    IO.inspect(buffer, label: "before")
    buffer = state.fun.(buffer)
    IO.inspect(buffer, label: "after")
    {{:ok, buffer: {:output, buffer}}, state}
  end

  @impl true
  def handle_playing_to_prepared(_ctx, state) do
    IO.puts("Handle playing to prepared")
    {:ok, state}
  end

  @impl true
  def handle_prepared_to_stopped(_ctx, state) do
    IO.puts("Ending Map element")
    {:ok, state}
  end
end
