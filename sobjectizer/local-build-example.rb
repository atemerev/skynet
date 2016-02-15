def detect_gcc_or_clang_version(cmd_name, tool_name)
  ver_regex = Regexp.new( "^#{tool_name} version (\\S+)" )
  result = IO.popen( "#{cmd_name} -v 2>&1", :err => :out ) do |io|
    target = 'generic'
    version = 'unknown'
    io.each_line do |line|
      if /^Target:\s*(?<trgt>\S+)/ =~ line
        target = trgt
      elsif ver_regex =~ line
        version = Regexp.last_match(1)
      end
    end
    version + '--' + target
  end
  puts "Detected #{tool_name} version & target: #{result}"
  result
end

def detect_gcc_version
  detect_gcc_or_clang_version('g++', 'gcc')
end

def detect_clang_version
  detect_gcc_or_clang_version('clang++', 'clang')
end

def detect_vc_version
  result = IO.popen( 'cl /?', :err => :out ) do |io|
    target = 'generic'
    version = 'unknown'
    io.each_line do |line|
      if /Optimizing Compiler Version (?<v>\S+) for (?<trgt>\S+)/ =~ line
        target = trgt
        version = v
        break
      end
    end
    version + '--' + target
  end
  puts "Detected VC++ version & target: #{result}"
  result
end

MxxRu::Cpp::composite_target do
  if 'gcc' == toolset.name
    global_obj_placement MxxRu::Cpp::RuntimeSubdirObjPlacement.new(
      '_gcc_' + detect_gcc_version )
  elsif 'vc' == toolset.name
    global_obj_placement MxxRu::Cpp::RuntimeSubdirObjPlacement.new(
      '_vc_' + detect_vc_version )
  elsif 'clang' == toolset.name
    global_obj_placement MxxRu::Cpp::RuntimeSubdirObjPlacement.new(
      '_clang_' + detect_clang_version )
  else
    version = toolset.tag( 'ver_hi', 'x' ) + '_' + toolset.tag( 'ver_lo', 'x' )
    global_obj_placement MxxRu::Cpp::RuntimeSubdirObjPlacement.new(
      '_' + toolset.name + '_' + version )
  end
   
  default_runtime_mode( MxxRu::Cpp::RUNTIME_RELEASE )
  MxxRu::enable_show_brief

  if 'vc' == toolset.name
    global_compiler_option '/W3'
=begin
    global_compiler_option '/Zi'
    global_linker_option '/DEBUG'
    global_linker_option '/Profile'
=end
  end

  if 'gcc' == toolset.name
    global_compiler_option '-Wextra'
    global_compiler_option '-Wall'
  end

  if 'clang' == toolset.name
    global_compiler_option '-Werror'
    global_compiler_option '-Weverything'
    global_compiler_option '-Wno-c++98-compat'
    global_compiler_option '-Wno-c++98-compat-pedantic'
    global_compiler_option '-Wno-padded'
    global_compiler_option '-Wno-missing-noreturn'
    global_compiler_option '-Wno-documentation-unknown-command'
    global_compiler_option '-Wno-documentation-deprecated-sync'
    global_compiler_option '-Wno-documentation'
    global_compiler_option '-Wno-weak-vtables'
    global_compiler_option '-Wno-missing-prototypes'
    global_compiler_option '-Wno-missing-variable-declarations'
    global_compiler_option '-Wno-exit-time-destructors'
    global_compiler_option '-Wno-global-constructors'
  end

end

# vim:ts=2:sw=2:expandtab
