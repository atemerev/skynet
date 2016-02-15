require 'mxx_ru/cpp'

MxxRu::Cpp::composite_target( MxxRu::BUILD_ROOT ) {

	toolset.force_cpp11
	global_include_path "."

	# If there is local options file then use it.
	if FileTest.exist?( "local-build.rb" )
		required_prj "local-build.rb"
	else
		default_runtime_mode( MxxRu::Cpp::RUNTIME_RELEASE )
		MxxRu::enable_show_brief
	end
	if 'gcc' == toolset.name || 'clang' == toolset.name
		global_linker_option '-pthread'
		if MxxRu::Cpp::RUNTIME_RELEASE == mxx_runtime_mode
			global_cpp_compiler_option '-O3'
			global_cpp_compiler_option '-mtune=native'
		end
	end

	required_prj 'skynet1m.rb'
	required_prj 'skynet1m-tp_disp.rb'
}
