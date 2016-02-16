require 'fileutils'
require 'open-uri'
require 'openssl'
require 'digest'

class AutoLoadSo5
	SO5_ARCH_SUBDIR = '.so5arch'
	SO5_ARCH_URL = 'https://github.com/masterspline/SObjectizer/archive/v5.5.15.2.zip'
	SO5_ARCH_NAME = 'so-5.5.15.2.zip'
	SO5_ARCH_TMP_NAME = SO5_ARCH_NAME + '.tmp'
	SO5_ARCH_SHA1 = '10fa54b61725a2369b40a469eacb99f47b97a8b5'
	SO5_MAIN_PATH = 'so_5'

	def load_and_unpack_if_necessary
		load_if_necessary
		unpack_if_necessary
	end

protected
	def load_if_necessary
		FileUtils.mkdir_p SO5_ARCH_SUBDIR, :verbose => true
		FileUtils.cd( SO5_ARCH_SUBDIR ) do
			if !File.exist?( SO5_ARCH_NAME )
				puts "Downloading #{SO5_ARCH_NAME} -> #{SO5_ARCH_TMP_NAME}..."
				length = 0
				File.open( SO5_ARCH_TMP_NAME, 'wb' ) do |f|
					IO.copy_stream(
						open( SO5_ARCH_URL, 'rb', {
								:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
								:content_length_proc => lambda do |size|
									length = size
								end,
								:progress_proc => lambda do |size|
									STDOUT.print "#{size}/#{length} bytes\r"
								end
							} ),
						f )
					puts
				end

				puts "Checking checksum for #{SO5_ARCH_TMP_NAME}..."
				chsum = Digest::SHA1.file( SO5_ARCH_TMP_NAME ).hexdigest
				if chsum != SO5_ARCH_SHA1
					raise "Checksum mismatch for #{SO5_ARCH_TMP_NAME}" 
				else
					FileUtils.mv SO5_ARCH_TMP_NAME, SO5_ARCH_NAME, :verbose => true
				end
			end
		end
	end

	def unpack_if_necessary
		if !Dir.exist?( SO5_MAIN_PATH )
		end
	end
end

if $0 == __FILE__
	AutoLoadSo5.new.load_and_unpack_if_necessary
end
