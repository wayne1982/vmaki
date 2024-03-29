require 'net/ssh'
require "libvirt"
require "xml/libxml"

class Volume < ActiveRecord::Base
	validates_uniqueness_of :name

  belongs_to :pool
	has_one :vm

	before_save :manage_save
	before_update :manage_update
	before_destroy :remove if APP_CONFIG["libvirt_integration"]

	attr_reader :not_enough_space
	@not_enough_space = false

	def manage_save
		# if the model already exists, go to do_update
		if self.new_record? && APP_CONFIG["libvirt_integration"]
			@pool = Pool.find(self.pool_id)
			@pool.update_pool_info
			# check if there's enough space
			puts "capacity: #{@pool.available}"
			puts "capacity: #{self.capacity}"
			if @pool.available.to_f > (self.capacity + 1).to_f
				puts "Creating volume"
				self.target_path = "#{@pool.name}/#{self.name}"
				# initialize libvirt part of the volume, but only if libvirt integration is enabled!
				libvirt_init if APP_CONFIG["libvirt_integration"]

				# update volume stats
				update_volume_info
			else
				@not_enough_space = true
				return false
			end
		else
			manage_update
		end
	end

	def manage_update
		puts "Updating volume"
		@pool = Pool.find(self.pool_id)	
		@host = Host.find(@pool.host_id)
		self.target_path = "#{@pool.name}/#{self.name}"

		connection = ConnectionsManager.instance
		connection_hash = connection.get(@host.name)
		@conn = connection_hash[:conn]

		# get a reference to the storage pool object
		@pool_ref = @conn.lookup_storage_pool_by_name(@pool.name)

		# refresh pool stats
		@pool_ref.refresh

		delta_size = (self.capacity.to_f - self.capacity_was.to_f).to_f
		# keep at least 1G free for the Host operating system, so increate delta_size by 1 if it's positive
		if delta_size > 0 :	delta_size += 1	end

		new_size_in_mb = (self.capacity * 1024).to_i

		puts "New Size: #{new_size_in_mb}"
		puts "Target Path: /dev/#{self.target_path}"
		Net::SSH.start(@host.name, @host.username, :auth_methods => "publickey", :timeout => Constants::SSH_Timeout) do |ssh|

			# check if volume contains a root filesystem and if yes, resize that as well (for PV Guests)
			if self.mkfs
				if self.vol_type == "root"
					# TODO: Check if filesystem is mounted!

					# check if volume is being grown or shrunk and if it's being grown, check if there's enough space available

					if (delta_size > 0) && (delta_size < @pool.available)
						# grow
						puts "growing volume"
						ssh.exec!("lvresize -L#{new_size_in_mb}M -n -f #{self.target_path}")
						@pool_ref.refresh
						sleep 2
						puts "growing filesystem"
						return ssh.exec!("resize2fs -f /dev/#{self.target_path} #{new_size_in_mb}M")
					elsif delta_size < 0
						# shrink
						puts "shrinking filesystem"
						ssh.exec!("resize2fs -f /dev/#{self.target_path} #{new_size_in_mb}M")
						sleep 2
						puts "shrinking volume"
						ssh.exec!("lvresize -L#{new_size_in_mb}M -n -f #{self.target_path}")
						@pool_ref.refresh
					else
						# there's not enough space!
						puts "there's not enough space!"
						@not_enough_space = true
						return false
					end
				end
			else
				puts "delta_size: #{delta_size}"
				# resize LVM Volume (for HVM Guests)
				# check if volume is being grown or shrunk and if it's being grown, check if there's enough space available
				puts "capacity: #{self.capacity}"
				puts "available: #{@pool.available}"
				if (delta_size > 0) && (delta_size < @pool.available)
					# grow
					return ssh.exec!("lvresize -L#{new_size_in_mb}M -n -f #{self.target_path}")
				elsif delta_size < 0
					# shrink
					return ssh.exec!("lvresize -L#{new_size_in_mb}M -n -f #{self.target_path}")
				else
					# there's not enough space!
					puts "there's not enough space!"
					@not_enough_space = true
					return false
				end
			end

		end

		# update volume stats
		update_volume_info
		
	end

	# create the volume
	def libvirt_init
		#@pool = Pool.find(self.pool_id)
		@host = Host.find(@pool.host_id)

		target_path = "/dev/#{self.target_path}"
		capacity = self.capacity.to_f * 1024 * 1024 * 1024

		connection = ConnectionsManager.instance
		connection_hash = connection.get(@host.name)
		@conn = connection_hash[:conn]

		# check if the pool has to be initialized first and if so, initialize it
		@pool.define_pool
		# get a reference to the storage pool object
		@pool_ref = @conn.lookup_storage_pool_by_name(@pool.name)

		# check if the volume already exists and remove it if needed
		remove

		# create the volume within the system (persistent)
		@pool_ref.create_vol_xml(to_libvirt_xml(target_path, capacity))

		# check if a filesystem has to be created (only for PV guests necessary)
		if self.mkfs
			# now check which filesystem has to be created (either ext3 or swap)
			if self.vol_type == "root"
				puts "Creating a root filesystem on #{target_path}"
				Net::SSH.start(@host.name, @host.username, :auth_methods => "publickey", :timeout => Constants::SSH_Timeout) do |ssh|
					return ssh.exec!("mkfs -t ext3 #{target_path}")
				end
			end
			if self.vol_type == "swap"
				puts "Creating a swap filesystem on #{target_path}"
				Net::SSH.start(@host.name, @host.username, :auth_methods => "publickey", :timeout => Constants::SSH_Timeout) do |ssh|
					return ssh.exec!("mkswap #{target_path}")
				end
			end
		end
	end

	private

	def remove
		@pool = Pool.find(self.pool_id)
		@host = Host.find(@pool.host_id)

		connection = ConnectionsManager.instance
		connection_hash = connection.get(@host.name)
		@conn = connection_hash[:conn]

		# check if the pool has to be initialized first and if so, initialize it
		@pool.define_pool
		# get a reference to a storage pool object
		@pool_ref = @conn.lookup_storage_pool_by_name(@pool.name)

		# delete the volume first (because it still might exist within the xen context)
		@pool_ref.refresh
		volumes = @pool_ref.list_volumes

		if volumes.include?(self.name)
			volume = @pool_ref.lookup_volume_by_name(self.name)
			puts "need to delete volume first"
			volume.delete
		end
	end

	def to_libvirt_xml(target_path, vol_capacity)
		# create a new XML document
		doc = XML::Document.new()
		# create the root element
		doc.root = XML::Node.new("volume")
		root = doc.root
		root["type"] = Constants::LVM

		# create name element
		root << name = XML::Node.new("name")
		name << self.name

		# create capacity element
		root << capacity = XML::Node.new("capacity")
		capacity << vol_capacity

		# create target parent element
		root << target = XML::Node.new("target")

		# create path element
		target << path = XML::Node.new("path")
		path << target_path

		# create permissions parent element
		target << permissions = XML::Node.new("permissions")

		# create mode element
		permissions << mode = XML::Node.new("mode")
		mode << Constants::PERMISSIONS_MODE

		# create owner element
		permissions << owner = XML::Node.new("owner")
		owner << Constants::PERMISSIONS_OWNER

		# create group element
		permissions << group = XML::Node.new("group")
		group << Constants::PERMISSIONS_GROUP

		return doc.to_s
	end

	# updates the model with all the latest details
	def update_volume_info
		#		@pool = Pool.find(self.pool_id)
		#		@host = Host.find(@pool.host_id)
		#
		#		connection = ConnectionsManager.instance
		#		connection_hash = connection.get(@host.name)
		#		conn = connection_hash[:conn]

		# get pool reference in order to get a reference to the volume
		@pool = @conn.lookup_storage_pool_by_name(@pool.name)
		volume = @pool.lookup_volume_by_name(self.name)
		volume_info = volume.info
		
		# add some stats to pool object
		divide_to_gigabytes = (1024 * 1024 * 1024).to_f
		self.allocation = (volume_info.allocation.to_f / divide_to_gigabytes).to_f
	end

	
end
