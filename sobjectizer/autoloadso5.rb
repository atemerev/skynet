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
	SUCCESS_MARK = File.join( SO5_MAIN_PATH, '.successful' )

	def load_and_unpack_if_necessary
		if does_unpack_needed
			load_if_necessary
			unpack_if_necessary
		end
	end

protected
	def load_if_necessary
		FileUtils.mkdir_p SO5_ARCH_SUBDIR, :verbose => true
		FileUtils.cd( SO5_ARCH_SUBDIR ) do
			if !File.exist?( SO5_ARCH_NAME )
				puts "Downloading #{SO5_ARCH_NAME} -> #{SO5_ARCH_TMP_NAME}..."
				File.open( SO5_ARCH_TMP_NAME, 'wb' ) do |f|
					IO.copy_stream(
						open( SO5_ARCH_URL, 'rb', {
								:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
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
		FileUtils.cd( SO5_ARCH_SUBDIR ) do
			FileUtils.rm_rf SO5_ARCH_UNPACKED_SUBDIR, :verbose => true
			puts "unpacking #{SO5_ARCH_NAME}"
			unpack_tar
		end

		move_necessary_folders
		remove_remaining_sources
		FileUtils.touch( SUCCESS_MARK )
	end
	
	def does_unpack_needed
		!File.exist?( SUCCESS_MARK )
	end

	def unpack_tar
		Gem::Package::TarReader.new( Zlib::GzipReader.open SO5_ARCH_NAME ) do |tar|
			tar.each do |entry|
				what = entry.full_name
				if entry.directory?
					FileUtils.mkdir_p what, :mode => entry.header.mode, :verbose => false
				elsif entry.file?
					File.open( what, "wb" ) { |f| f.print entry.read }
					FileUtils.chmod entry.header.mode, what, :verbose => false
				end
			end
		end
	end

	def move_necessary_folders
		%w{ so_5 timertt }.each do |d|
			FileUtils.rm_rf d, :verbose => true
			src = File.join SO5_ARCH_SUBDIR, SO5_ARCH_UNPACKED_SUBDIR, 'dev', d
			FileUtils.mv src, '.', :verbose => true
		end
	end

	def remove_remaining_sources
		FileUtils.rm_rf File.join( SO5_ARCH_SUBDIR, SO5_ARCH_UNPACKED_SUBDIR ),
			:verbose => true
	end
end

if $0 == __FILE__
	AutoLoadSo5.new.load_and_unpack_if_necessary
end
