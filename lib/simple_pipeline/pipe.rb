module SimplePipeline

	class Pipe

		DEFAULT_OPTIONS = {}

		def initialize (options = {})
			@options = DEFAULT_OPTIONS.merge(options)
			@blocks = {}
			@block_order = []
		end

		def add (block, block_id = nil)
			begin
				raise ArgumentError, "invalid block - incorrect number of arguments for process() method (should be 1)" unless block.class.instance_method(:process).arity == 1
			rescue NameError
				raise ArgumentError, "invalid block - process() method not found"
			end

			id = block_id.nil? ? block.class.to_s : block_id.to_s
			raise ArgumentError, "block id '#{id}' already used" if @blocks.has_key?(id)

			@blocks[id] = block
			@block_order << id

			return id
		end

		def size
			return @blocks_order.size
		end

		def process (payload)
			@block_order.each do |block_id|
				@blocks[block_id].process(payload)
			end
		end

		alias :length :size
	end

end
