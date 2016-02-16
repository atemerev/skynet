require 'fileutils'
require 'open-uri'
require 'openssl'
require 'digest'
require 'zlib'
require 'rubygems/package'

class AutoLoadSo5
	SO5_ARCH_SUBDIR = '.so5arch'
	SO5_ARCH_UNPACKED_SUBDIR = 'SObjectizer-5.5.15.2'

	SO5_ARCH_URL = 'https://github.com/masterspline/SObjectizer/archive/v5.5.15.2.tar.gz'
	SO5_ARCH_NAME = 'so-5.5.15.2.tar.gz'
	SO5_ARCH_TMP_NAME = SO5_ARCH_NAME + '.tmp'
	SO5_ARCH_SHA1 = '834247d8bd7a9688bf3540f036520ada290e530b'
	SO5_MAIN_PATH = 'so_5'
	SUCCESS_MARK = '.successful'

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
					raise "Checksum mismatch for #{SO5_ARCH_TMP_NAME}: actual is #{chsum}" 
				else
					FileUtils.mv SO5_ARCH_TMP_NAME, SO5_ARCH_NAME, :verbose => true
				end
			end
		end
	end

	def unpack_if_necessary
		return unless does_unpack_needed

		puts "unpacking #{SO5_ARCH_NAME}"
		FileUtils.cd( SO5_ARCH_SUBDIR ) do
			FileUtils.rm_rf SO5_ARCH_UNPACKED_SUBDIR, :verbose => true
			unpack_tar
			move_necessary_folders
		end
	end
	
	def does_unpack_needed
		if Dir.exist?( SO5_MAIN_PATH )
			if File.exist?( File.join( SO5_MAIN_PATH, SUCCESS_MARK ) )
				return false
			end
		end

		true
	end

	def unpack_tar
		Gem::Package::TarReader.new( Zlib::GzipReader.open SO5_ARCH_NAME ) do |tar|
			tar.each do |entry|
				what = entry.full_name
				if entry.directory?
					FileUtils.mkdir_p what, :mode => entry.header.mode, :verbose => true
				elsif entry.file?
					File.open( what, "wb" ) { |f| f.print entry.read }
					FileUtils.chmod entry.header.mode, what, :verbose => true
				end
			end
		end
	end

	def move_necessary_folders
	end

end

if $0 == __FILE__
	AutoLoadSo5.new.load_and_unpack_if_necessary
end
