defmodule State do
  defstruct socket_pid: nil
end

defmodule RiakClient do
  @moduledoc """
  Riak Client
  """
  use GenServer

  def start_link(opt \\ []) do
    IO.puts("Starting Riak Client Worker...")
    GenServer.start_link(__MODULE__, :ok, opt)
  end

  def init(:ok) do
    configure(Riak, host: '127.0.0.1', port: 8087)
    IO.puts("Riak Client init")
    { :ok, nil }
  end

#  defmacro __using__(_opts) do
#    quote do

      # Client level functions
      def configure(server, opts) do
        GenServer.call(server, {:configure, Keyword.fetch!(opts, :host), Keyword.fetch!(opts, :port)})
      end

      @doc "Ping a Riak instance"
      def ping(server), do: GenServer.call(server, {:ping})

      def put(server, obj), do: GenServer.call(server, {:store, obj})

      def find(server, bucket, key), do: GenServer.call(server, {:fetch, bucket, key})

      def resolve(server, bucket, key, index) do
        GenServer.call(server, {:resolve, bucket, key, index})
      end

      @doc "Delete an object from a bucket"
      def delete(server, bucket, key), do: GenServer.call(server, {:delete, bucket, key})
      def delete(server, obj), do: GenServer.call(server, {:delete, obj.bucket, obj.key})

      # Riak modules and functions
      defmodule Bucket do
        def list(server), do: GenServer.call(server, {:list_buckets})
        def list(server, timeout), do: GenServer.call(server, {:list_buckets, timeout})

        def keys(server, bucket), do: GenServer.call(server, {:list_keys, bucket})
        def keys(server, bucket, timeout), do: GenServer.call(server, {:list_keys, bucket, timeout})

        def get(server, bucket), do: GenServer.call(server, {:props, bucket})
        #Possible Props: [n_val: 3, allow_mult: false, last_write_wins: false, basic_quorum: false, notfound_ok: true, precommit: [], postcommit: [], pr: 0, r: :quorum, w: :quorum, pw: 0, dw: :quorum, rw: :quorum]}

        def put(server, bucket, props), do: GenServer.call(server, {:set_props, bucket, props})
        def put(server, bucket, type, props), do: GenServer.call(server, {:set_props, bucket, type, props})

        def reset(server, bucket), do: GenServer.call(server, {:reset, bucket})

        defmodule Type do
          def get(server, type), do: GenServer.call(server, {:get_type, type})
          def put(server, type, props), do: GenServer.call(server, {:set_type, type, props})
          def reset(server, type), do: GenServer.call(server, {:reset_type, type})
        end
      end

      defmodule Index do
        def query(server, bucket, {type, name}, key, opts) do 
          case GenServer.call(server, {:index_eq_query, bucket, {type, name}, key, opts}) do
            {:ok, {:index_results_v1, keys, terms, continuation}} -> {keys, terms, continuation}
            res -> res
          end
        end
        def query(server, bucket, {type, name}, startkey, endkey, opts) do
          case GenServer.call(server, {:index_range_query, bucket, {type, name}, startkey, endkey, opts}) do
            {:ok, {:index_results_v1, keys, terms, continuation}} -> {keys, terms, continuation}
            res -> res
          end
        end
      end

      defmodule Mapred do
        def query(server, inputs, query), do: GenServer.call(server, {:mapred_query, inputs, query})
        def query(server, inputs, query, timeout) do
          GenServer.call(server, {:mapred_query, inputs, query, timeout})
        end
        
        defmodule Bucket do
          def query(server, bucket, query), do: GenServer.call(server, {:mapred_query_bucket, bucket, query})
          def query(server, bucket, query, timeout) do
            GenServer.call(server, {:mapred_query_bucket, bucket, query, timeout})
          end
        end
      end

      defmodule Search do
        def query(server, bucket, query, options) do
          GenServer.call(server, {:search_query, bucket, query, options})
        end
        def query(server, bucket, query, options, timeout) do
          GenServer.call(server, {:search_query, bucket, query, options, timeout})
        end
        
        defmodule Index do
          def list(server), do: GenServer.call(server, {:search_list_indexes})
          def put(server, bucket), do: GenServer.call(server, {:search_create_index, bucket})
          def get(server, bucket), do: GenServer.call(server, {:search_get_index, bucket})
          def delete(server, bucket), do: GenServer.call(server, {:search_delete_index, bucket})
        end

        defmodule Schema do
          def get(server, bucket), do: GenServer.call(server, {:search_get_schema, bucket})

          def create(server, bucket, content) do
            GenServer.call(server, {:search_create_schema, bucket, content})
          end
        end
      end

      defmodule Counter do
        def enable(server, bucket), do: Bucket.put("#{bucket}-counter", [{:allow_mult, true}])

        def increment(server, bucket, name, amount) do
          GenServer.call(server, {:counter_incr, "#{bucket}-counter", name, amount})
        end

        def value(server, bucket, name) do 
          case GenServer.call(server, {:counter_val, "#{bucket}-counter", name}) do
            {:ok, val} -> val
            val -> val
          end
        end
      end # Counter

#    end  # quote
#  end # defmacro

  def build_sibling_list([{_md, val}|t], final_list), do: build_sibling_list(t,[val|final_list])
  def build_sibling_list([], final_list), do: final_list
  

  # Start Link to Riak
  def handle_call({ :configure, host, port }, _from, _state) do
    {:ok, pid} = :riakc_pb_socket.start_link(host, port)
    new_state = %State{socket_pid: pid}
    { :reply, {:ok, pid}, new_state }
  end

  # Ping Riak
  def handle_call({ :ping }, _from, state) do
      { :reply, :riakc_pb_socket.ping(state.socket_pid), state }
  end

  # Store a Riak Object
  def handle_call({:store, obj }, _from, state) do
    case :riakc_pb_socket.put(state.socket_pid, obj.to_robj()) do
      {:ok, new_object} ->
        { :reply, obj.key(:riakc_obj.key(new_object)), state }
      :ok -> 
        { :reply, obj, state }
      _ ->
        { :reply, nil, state }
    end
  end

  # Fetch a Riak Object
  def handle_call({:fetch, bucket, key }, _from, state) do
    case :riakc_pb_socket.get(state.socket_pid, bucket, key) do
      {:ok, object} ->
        if :riakc_obj.value_count(object) > 1 do
          { :reply, build_sibling_list(:riakc_obj.get_contents(object),[]), state }
        else
          { :reply, RObj.from_robj(object), state }
        end
      _ -> { :reply, nil, state }
    end
  end

  # Resolve a Riak Object
  def handle_call({:resolve, bucket, key, index }, _from, state) do
    case :riakc_pb_socket.get(state.socket_pid, bucket, key) do
      {:ok, object} ->
        new_object = :riakc_obj.select_sibling(index, object)
        { :reply, :riakc_pb_socket.put(state.socket_pid, new_object), state }
      _ -> { :reply, nil, state }
    end
  end

  # Delete a Riak Object
  def handle_call({:delete, bucket, key }, _from, state) do
    { :reply, :riakc_pb_socket.delete(state.socket_pid, bucket, key), state }
  end

  def handle_call({:list_buckets, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.list_buckets(state.socket_pid, timeout), state}
  end

  def handle_call({:list_buckets}, _from, state) do
    { :reply, :riakc_pb_socket.list_buckets(state.socket_pid), state}
  end

  def handle_call({:list_keys, bucket, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.list_keys(state.socket_pid, bucket, timeout), state}
  end

  def handle_call({:list_keys, bucket}, _from, state) do
    { :reply, :riakc_pb_socket.list_keys(state.socket_pid, bucket), state}
  end

  def handle_call({:props, bucket}, _from, state) do
    { :reply, :riakc_pb_socket.get_bucket(state.socket_pid, bucket), state}
  end

  def handle_call({:set_props, bucket, props}, _from, state) do
    { :reply, :riakc_pb_socket.set_bucket(state.socket_pid, bucket, props), state}
  end

  def handle_call({:set_props, bucket, type, props}, _from, state) do
    { :reply, :riakc_pb_socket.set_bucket(state.socket_pid, {type, bucket}, props), state}
  end

  def handle_call({:reset, bucket}, _from, state) do
    { :reply, :riakc_pb_socket.reset_bucket(state.socket_pid, bucket), state}
  end

  def handle_call({:get_type, type}, _from, state) do
    { :reply, :riakc_pb_socket.get_bucket_type(state.socket_pid, type), state}
  end

  def handle_call({:set_type, type, props}, _from, state) do
    { :reply, :riakc_pb_socket.set_bucket_type(state.socket_pid, type, props), state}
  end
    
  def handle_call({:reset_type, type}, _from, state) do
    { :reply, :riakc_pb_socket.reset_bucket_type(state.socket_pid, type), state}
  end

  def handle_call({:mapred_query, inputs, query}, _from, state) do
    { :reply, :riakc_pb_socket.mapred(state.socket_pid, inputs, query), state}
  end

  def handle_call({:mapred_query, inputs, query, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.mapred(state.socket_pid, inputs, query, timeout), state}
  end

  def handle_call({:mapred_query_bucket, bucket, query}, _from, state) do
    { :reply, :riakc_pb_socket.mapred_bucket(state.socket_pid, bucket, query), state}
  end

  def handle_call({:mapred_query_bucket, bucket, query, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.mapred_bucket(state.socket_pid, bucket, query, timeout), state}
  end

  def handle_call({:index_eq_query, bucket, {type, name}, key, opts}, _from, state) do
    {:ok, name} = String.to_char_list(name)
    { :reply, :riakc_pb_socket.get_index_eq(state.socket_pid, bucket, {type, name}, key, opts), state}
  end

  def handle_call({:index_range_query, bucket, {type, name}, startkey, endkey, opts}, _from, state) do
    {:ok, name} = String.to_char_list(name)
    { :reply, :riakc_pb_socket.get_index_range(state.socket_pid, bucket, {type, name}, startkey, endkey, opts), state}
  end
  
  def handle_call({:search_list_indexes}, _from, state) do
    { :reply, :riakc_pb_socket.list_search_indexes(state.socket_pid), state}
  end

  def handle_call({:search_create_index, index}, _from, state) do
    { :reply, :riakc_pb_socket.create_search_index(state.socket_pid, index), state}
  end

  def handle_call({:search_get_index, index}, _from, state) do
    { :reply, :riakc_pb_socket.get_search_index(state.socket_pid, index), state}
  end

  def handle_call({:search_delete_index, index}, _from, state) do
    { :reply, :riakc_pb_socket.delete_search_index(state.socket_pid, index), state}
  end

  def handle_call({:search_get_schema, name}, _from, state) do
    { :reply, :riakc_pb_socket.get_search_schema(state.socket_pid, name), state}
  end

  def handle_call({:search_create_schema, name, content}, _from, state) do
    { :reply, :riakc_pb_socket.create_search_schema(state.socket_pid, name, content), state}
  end

  def handle_call({:search_query, index, query, options}, _from, state) do
    { :reply, :riakc_pb_socket.search(state.socket_pid, index, query, options), state}
  end

  def handle_call({:search_query, index, query, options, timeout}, _from, state) do
    { :reply, :riakc_pb_socket.search(state.socket_pid, index, query, options, timeout), state}
  end

  def handle_call({:counter_incr, bucket, key, amount}, _from, state) do
    { :reply, :riakc_pb_socket.counter_incr(state.socket_pid, bucket, key, amount), state}
  end

  def handle_call({:counter_val, bucket, key}, _from, state) do
    { :reply, :riakc_pb_socket.counter_val(state.socket_pid, bucket, key), state}
  end
end
