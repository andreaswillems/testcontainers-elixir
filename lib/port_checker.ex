# SPDX-License-Identifier: Apache-2.0
defmodule TestcontainersElixir.PortChecker do
  @doc """
  Waits for tcp service to be ready at the specified IP and port.

  This doesn't mean that the service is ready to accept requests.

  ## Params:
  - ip: The IP address as a string.
  - port: The port number as an integer.
  - timeout: The maximum time to wait (in milliseconds) as an integer.
  """
  def wait_for_port(ip, port, timeout \\ 1000)
      when is_binary(ip) and is_integer(port) and is_integer(timeout) do
    wait_for_port(ip, port, timeout, :os.system_time(:millisecond))
  end

  defp wait_for_port(ip, port, timeout, start_time)
       when is_binary(ip) and is_integer(port) and is_integer(timeout) and is_integer(start_time) do
    if timeout + start_time < :os.system_time(:millisecond) do
      {:error, :timeout}
    else
      if port_open?(ip, port) do
        {:ok, :port_is_open}
      else
        # Sleep for 500 ms, then retry
        :timer.sleep(500)
        wait_for_port(ip, port, timeout, start_time)
      end
    end
  end

  defp port_open?(ip, port, timeout \\ 1000)
       when is_binary(ip) and is_integer(port) and is_integer(timeout) do
    IO.inspect("checking port #{port}")

    case :gen_tcp.connect(~c"#{ip}", port, [:binary, active: false], timeout) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        true

      {:error, _reason} ->
        false
    end
  end
end