HAXE=haxe
ADL=adl
ADT=adt
SWF=bin/Swivel.swf
CERT_PASS=ngswivel!430
PACKAGE_FILES=application.xml $(SWF) ffmpeg/mac64 ffmpeg/licenses assets/icons README.md LICENSE.md
ADTFLAGS=-package -storetype pkcs12 -keystore bat/Swivel.p12 -storepass $(CERT_PASS) -target bundle bin/Swivel					
HXML_FILE=Swivel.hxml
APP_PATH=bin/Swivel.app
DMG_PATH=bin/Swivel.dmg

.PHONY: clean package debug run

all: package

run: $(SWF)
	$(ADL) application.xml .

debug:
	# Force rebuild with debug parameters.
	$(HAXE) $(HXML_FILE) -debug -D fdb
	$(ADL) application.xml .

package: $(DMG_PATH)

clean:
	rm -rf bin

$(SWF): $(HXML_FILE)
	$(HAXE) $(HXML_FILE) $(HXML_FLAGS)

$(DMG_PATH): $(APP_PATH) mac-installer.json
	# Use appdmg to build the DMG image.
	rm -rf $(DMG_PATH)
	appdmg mac-installer.json $(DMG_PATH)

$(APP_PATH): $(SWF) $(PACKAGE_FILES)
	# Package app using ADT.
	$(ADT) $(ADTFLAGS) $(PACKAGE_FILES)
	# Create debug file to force AIR app into Debug mode.
	# This is necessary to use the System.pause methods in AS3.
	touch bin/Swivel.app/Contents/Resources/META-INF/debug

	