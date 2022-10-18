# defmodule Cim.Sandbox do
#   use GenServer

#   def start_link(room_script) do
#     GenServer.start_link(
#       __MODULE__,
#       room_script,
#       name: pid(room_script),
#       id: room_script
#     )
#   end

#   def pid(room_script) do
#     {:global, {Game.Room, room_script}}
#   end

#   def init(room_script) do
#     root = :luerl.init()
#     {_result, state} = :luerl.dofile(room_script |> String.to_charlist(), state)
#     {:ok, state}
#   end
# end
