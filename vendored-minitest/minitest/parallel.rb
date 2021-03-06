module Minitest
  module Parallel

    ##
    # The engine used to run multiple tests in parallel.

    class Executor

      ##
      # The size of the pool of workers.

      attr_reader :size

      ##
      # Create a parallel test executor of with +size+ workers.

      def initialize size
        @size  = size
        @queue = Queue.new
        # @pool  = size.times.map {
        #   Thread.new(@queue) do |queue|
        #     Thread.current.abort_on_exception = true
        #     while job = queue.pop
        #       klass, method, reporter = job
        #       result = Minitest.run_one_method klass, method
        #       reporter.synchronize { reporter.record result }
        #     end
        #   end
        # }
      end

      ##
      # Add a job to the queue

      def << work; @queue << work; end

      ##
      # Shuts down the pool of workers by signalling them to quit and
      # waiting for them all to finish what they're currently working
      # on.

      def shutdown
        # size.times { @queue << nil }
        # @pool.each(&:join)
        @queue.each do |job|
          klass, method, reporter = job
          result = Minitest.run_one_method klass, method
          reporter.record result
          # reporter.synchronize { reporter.record result }
        end
      end
    end

    module Test
      def _synchronize; Test.io_lock.synchronize { yield }; end # :nodoc:

      module ClassMethods
        def run_one_method klass, method_name, reporter # :nodoc:
          Minitest.parallel_executor << [klass, method_name, reporter]
        end
        def test_order; :parallel; end # :nodoc:
      end
    end
  end
end
