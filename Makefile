clean:
	swift package clean

build: clean
	swift package resolve
	swift build --configuration release
