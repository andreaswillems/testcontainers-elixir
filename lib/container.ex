# SPDX-License-Identifier: MIT
# Original by: Marco Dallagiacoma @ 2023 in https://github.com/dallagi/excontainers
# Modified by: Jarl André Hübenthal @ 2023
defmodule Testcontainers.Container do
  @moduledoc """
  A struct with builder functions for creating a definition of a container.
  """

  @enforce_keys [:image]
  defstruct [
    :image,
    cmd: nil,
    environment: %{},
    exposed_ports: [],
    ip_address: nil,
    wait_strategies: [],
    privileged: false,
    bind_mounts: [],
    bind_volumes: [],
    labels: %{},
    auto_remove: false,
    container_id: nil
  ]

  @doc """
  A constructor function to make it easier to construct a container
  """
  def new(image) when is_binary(image) do
    %__MODULE__{image: image}
  end

  @doc """
  Sets a _waiting strategy_ for the _container_.
  """
  def with_waiting_strategy(%__MODULE__{} = config, wait_fn) when is_struct(wait_fn) do
    %__MODULE__{config | wait_strategies: [wait_fn | config.wait_strategies]}
  end

  @doc """
  Sets multiple _waiting strategies_ for the _container_.
  """
  def with_waiting_strategies(%__MODULE__{} = config, wait_fns) when is_list(wait_fns) do
    Enum.reduce(wait_fns, config, fn fun, cfg -> with_waiting_strategy(cfg, fun) end)
  end

  @doc """
  Sets an _environment variable_ to the _container_.
  """
  def with_environment(%__MODULE__{} = config, key, value)
      when (is_binary(key) or is_atom(key)) and is_binary(value) do
    %__MODULE__{config | environment: Map.put(config.environment, key, value)}
  end

  @doc """
  Adds a _port_ to be exposed on the _container_.
  """
  def with_exposed_port(%__MODULE__{} = config, port) when is_integer(port) do
    filtered_ports = config.exposed_ports |> Enum.reject(fn p -> p == port end)

    %__MODULE__{config | exposed_ports: [port | filtered_ports]}
  end

  @doc """
  Adds a fixed _port_ to be exposed on the _container_.
  This approach to managing ports is not recommended by Testcontainers.
  Use at your own risk.
  """
  def with_fixed_port(%__MODULE__{} = config, port, host_port \\ nil)
      when is_integer(port) and (is_nil(host_port) or is_integer(host_port)) do
    filtered_ports = config.exposed_ports |> Enum.reject(fn p -> p == port end)

    %__MODULE__{
      config
      | exposed_ports: [
          {port, host_port || port} | filtered_ports
        ]
    }
  end

  @doc """
  Adds multiple _ports_ to be exposed on the _container_.
  """
  def with_exposed_ports(%__MODULE__{} = config, ports) when is_list(ports) do
    filtered_ports = config.exposed_ports |> Enum.reject(fn port -> port in ports end)

    %__MODULE__{config | exposed_ports: ports ++ filtered_ports}
  end

  @doc """
  Sets a file or the directory on the _host machine_ to be mounted into a _container_.
  """
  def with_bind_mount(%__MODULE__{} = config, host_src, container_dest, options \\ "ro")
      when is_binary(host_src) and is_binary(container_dest) and is_binary(options) do
    new_bind_mount = %{host_src: host_src, container_dest: container_dest, options: options}
    %__MODULE__{config | bind_mounts: [new_bind_mount | config.bind_mounts]}
  end

  @doc """
  Sets a volume to be mounted into a container on target path
  """
  def with_bind_volume(%__MODULE__{} = config, volume, container_dest, read_only \\ false)
      when is_binary(volume) and is_binary(container_dest) and is_boolean(read_only) do
    new_bind_volume = %{
      volume: volume,
      container_dest: container_dest,
      read_only: read_only
    }

    %__MODULE__{config | bind_volumes: [new_bind_volume | config.bind_volumes]}
  end

  @doc """
  Sets a label to apply to the container object in docker.
  """
  def with_label(%__MODULE__{} = config, key, value) when is_binary(key) and is_binary(value) do
    %__MODULE__{config | labels: Map.put(config.labels, key, value)}
  end

  @doc """
  Sets a cmd to run when the container starts.
  """
  def with_cmd(%__MODULE__{} = config, cmd) when is_list(cmd) do
    %__MODULE__{config | cmd: cmd}
  end

  @doc """
  Sets whether the container should be automatically removed on exit.
  """
  def with_auto_remove(%__MODULE__{} = config, auto_remove) when is_boolean(auto_remove) do
    %__MODULE__{config | auto_remove: auto_remove}
  end

  @doc """
  Gets the host port on the container for the given exposed port.
  """
  def mapped_port(%__MODULE__{} = container, port) when is_number(port) do
    container.exposed_ports
    |> Enum.filter(fn
      {exposed_port, _} -> exposed_port == port
      port -> port == port
    end)
    |> List.first({})
    |> Tuple.to_list()
    |> List.last()
  end

  defimpl Testcontainers.ContainerBuilder do
    @impl true
    def build(%Testcontainers.Container{} = config) do
      config
    end

    @impl true
    @spec is_starting(%Testcontainers.Container{}, %Testcontainers.Container{}, %Tesla.Env{}) ::
            :ok
    def is_starting(_config, _container, _conn), do: :ok
  end
end
