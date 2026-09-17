# Flutter's own engine and plugin-generated code already ships correct keep
# rules via consumer proguard files; this project has no custom native/reflection
# code that R8 could break, so nothing extra is required here today.
# Add rules here only if a specific release-build crash traces back to R8
# stripping/obfuscating something reflection-based (e.g. a future plugin).
