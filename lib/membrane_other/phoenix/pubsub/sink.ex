defmodule MembraneOther.Phoenix.PubSub.Sink do
  use Membrane.Sink

  def_options(
    channel: [
      spec: :any,
      default: nil,
      description: "Channel that will be broadcast to."
    ],
    module: [
      spec: :any,
      default: nil,
      description: "PubSub module to use."
    ]
  )

  def_input_pad(:input,
    demand_unit: :buffers,
    caps: :any
  )

  @impl true
  def handle_init(%__MODULE{channel: channel, module: module}) do
    {:ok, %{channel: channel, module: module}}
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
    Phoenix.PubSub.broadcast(state.module, state.channel, {:result, buffer.payload})
    {{:ok, []}, state}
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
