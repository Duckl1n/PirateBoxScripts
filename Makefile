NAME = piratebox-scripts
VERSION = 0.4
ARCH = all
PB_FOLDER=piratebox
PB_SRC_FOLDER=$(PB_FOLDER)/$(PB_FOLDER)

PACKAGE_NAME=$(NAME)_$(VERSION)
PACKAGE=$(PACKAGE_NAME).tar.gz
VERSION_FILE=$(PB_FOLDER)/$(PB_FOLDER)/version

IMAGE_FILE=piratebox_img.gz
TGZ_IMAGE_FILE=piratebox_img.tar.gz
SRC_IMAGE=image_stuff/OpenWRT.img.gz
SRC_IMAGE_UNPACKED=image_stuff/piratebox_img
MOUNT_POINT=image_stuff/image
OPENWRT_FOLDER=image_stuff/openwrt
OPENWRT_CONFIG_FOLDER=$(OPENWRT_FOLDER)/conf


.DEFAULT_GOAL = package

$(VERSION):	
	echo "$(PACKAGE_NAME)" >  $(VERSION_FILE)

$(PACKAGE):  $(VERSION)
	tar czf $@ $(PB_FOLDER) 


$(IMAGE_FILE): $(SRC_IMAGE_UNPACKED) $(OPENWRT_CONFIG_FOLDER)
	mkdir -p  $(MOUNT_POINT)
	echo "#### Mounting image-file"
	su -c "mount -o loop,rw,sync $(SRC_IMAGE_UNPACKED) $(MOUNT_POINT)"
	echo "#### Copy content to image file"
	su -c " cp -vr $(PB_SRC_FOLDER)/*  $(MOUNT_POINT)     "
	echo "#### Copy customizatiosns to image file"
	su -c " cp -rv $(OPENWRT_FOLDER)/* $(MOUNT_POINT)/ "
	echo "#### Umount Image file"
	su -c "umount  $(MOUNT_POINT)"
	gzip -rc $(SRC_IMAGE_UNPACKED) > $(IMAGE_FILE)


$(OPENWRT_CONFIG_FOLDER):
	mkdir -p $@
	cp -rv $(PB_SRC_FOLDER)/conf/* $@
	sed 's:OPENWRT="no":OPENWRT="yes":'  -i $@/piratebox.conf 
	sed 's:DO_IFCONFIG="yes":DO_IFCONFIG="no":'  -i $@/piratebox.conf 
	sed 's:USE_APN="yes":USE_APN="no":'  -i $@/piratebox.conf 
	sed 's:DNSMASQ_INTERFACE="-i wlan0":DNSMASQ_INTERFACE="":' -i $@/piratebox.conf 
	sed 's:192.168.77:192\.168.1:g' -i $@/piratebox.conf 
	sed 's:192.168.77:192.168.1:g' -i $@/hosts 

$(TGZ_IMAGE_FILE):
	tar czf  $(TGZ_IMAGE_FILE) $(SRC_IMAGE_UNPACKED) 


$(SRC_IMAGE_UNPACKED):
	gunzip -dc $(SRC_IMAGE) >  $(SRC_IMAGE_UNPACKED)


package:  $(PACKAGE)

all: $(PACKAGE) shortimage

clean: cleanimage 
	rm -f $(PACKAGE)
	rm -f $(VERSION_FILE)

cleanimage:
	- rm -f  $(TGZ_IMAGE_FILE)
	- rm -f  $(SRC_IMAGE_UNPACKED)
	- rm -fr $(OPENWRT_CONFIG_FOLDER)
	- rm -v  $(IMAGE_FILE)


shortimage: $(IMAGE_FILE) $(TGZ_IMAGE_FILE)



.PHONY: all clean package shortimage

