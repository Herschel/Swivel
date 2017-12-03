HAXE=haxe
ADL=adl
ADT=adt
ADTFLAGS=-package -storetype pkcs12 -keystore bat/Swivel.p12 -target bundle bin/Swivel application.xml $(SWF) assets/icons ffmpeg/mac64 ffmpeg/licenses license.txt
HXML_FILE=Swivel.hxml
SWF=bin/Swivel.swf
OUTPUTINSTALLER=bin/Swivel.dmg

all: $(SWF) package

package:
	$(ADT) $(ADTFLAGS)

debug: HXMLFLAGS=-debug -D fdb
debug: $(SWF)
	$(ADL) application.xml .

release: $(SWF)
	$(ADL) application.xml .

clean:
	rm -rf $(SWF)

$(SWF): $(HXML_FILE)
	$(HAXE) $(HXML_FILE) $(HXMLFLAGS)
