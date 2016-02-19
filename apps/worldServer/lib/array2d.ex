defmodule Array2D do

  def new(width, height) do
    :array.new([{:size,height}, {:fixed,:true}, {:default, 
      :array.new([{:size,width}, {:fixed,:true} ])}])
  end

  def get(array, x, y), do: :array.get(x, :array.get(y, array))

  # Warning. Array is immutable. a new array is returned.
  def set(array, x, y, value) do
    line = :array.get(x, array)
    :array.set(x, :array.set(y, value, line), array)
  end

  def map(array, func) do
    :array.map(fn (i, v) ->
      :array.map(fn (ii,vv) -> func.(ii,vv) end, i) end, array)
  end

end
