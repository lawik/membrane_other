defmodule MembraneOther.Pipeline do
    use Membrane.Pipeline

    @impl true
    def handle_init(opts) do
      infile = Keyword.fetch!(opts, :infile)
      outfile = Keyword.fetch!(opts, :outfile)
      completion_pid = Keyword.fetch!(opts, :completion_pid)

      children = %{
        file_in: %Membrane.File.Source{location: infile},
        upper: %MembraneOther.Map{
          fun: fn buffer ->
            %{ buffer | payload: String.upcase(buffer.payload) }
          end
        },
        file_out: %Membrane.File.Sink{location: outfile}
      }

      links = [
        link(:file_in) |> to(:upper) |> to(:file_out)
      ]

      {{:ok, spec: %ParentSpec{children: children, links: links}, playback: :playing}, %{to_pid: completion_pid}}
    end

    @impl true
    def handle_shutdown(reason, state) do
      :ok
    end

    @impl true
    def handle_notification(notification, element, _context, state) do
      IO.inspect(notification, label: "notification")
      IO.inspect(element, label: "element")
      {:ok, state}
    end

    @impl true
    def handle_element_end_of_stream({:file_out, :input}, _context, state) do
      IO.puts("file sink complete")
      send(state.to_pid, :done)
      terminate(self())
      {{:ok, playback: :stopped}, state}
    end

    @impl true
    def handle_element_end_of_stream(_, _context, state) do
      {:ok, state}
    end

    @impl true
    def handle_prepared_to_stopped(_context, state) do
      IO.puts("terminating pipeline")
      send(state.to_pid, :shutdown)
      {:ok, state}
    end
  end
