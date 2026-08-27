<img src="resources/KBRD.svg" width="400">

# Description

`KBRD` is a POC for building a keyboard using the Maglev effect. It uses a Raspberry CM4 board (or any other Raspberry with eMMC storage), a DSI display, and key position detection using Hall effect sensors. The project includes a web interface for configuring the keyboard via the Wi-Fi network.

# Modules

|Module|Description|
|-|-|
|[KBRD-OS](https://github.com/ubikyo/kbrd-os)|Operating system for the keyboard|
|[KBRD-DEV](https://github.com/ubikyo/kbrd-dev)|Software embedded on the Raspberry to display the keyboard|
|[KBRD-API](https://github.com/ubikyo/kbrd-api)|REST API for communication between modules|
|[KBRD-WEB](https://github.com/ubikyo/kbrd-web)|Web interface for keyboard configuration|
|[KBRD-PLUGINS](https://github.com/ubikyo/kbrd-plugins)|Plugins shared between the web interface and the keyboard|
|[KBRD-AGENT](https://github.com/ubikyo/kbrd-agent)|Desktop agent used to invoke applications through KBRD-API|

# Development

Development is associated with the following components:

|Component|Description|
|-|-|
|[Raspberry Compute Module 4](https://www.raspberrypi.com/products/compute-module-4/)|Raspberry in a compact form factor|
|[Waveshare CM4-IO-BASE-A](https://www.waveshare.com/wiki/CM4-IO-BASE-A)|Waveshare development board for Raspberry CM4|
|[Waveshare 10.1-DSI-TOUCH-A](https://www.waveshare.com/wiki/10.1-DSI-TOUCH-A)|DSI display|
|[SH-U07A](https://www.deshide.com/product-details_SH-U07A.html)|Optional, a USB-to-TTL adapter connected between the GND/RX/TX ports of the adapter and the CM4-IO-BASE-A to access the `ttyAMA0` console.|

## Repository deployment

Clone the repository and its submodules:

```
git clone --recurse-submodules https://github.com/ubikyo/kbrd.git
```

## Configuration

Use the following command to generate an SSH key for the kbrd user and attach the submodules to their main branch:

```
cd kbrd
make configure
```

## Compilation

Compile all modules using one of the following commands:

|Script|Quiet|Log level|Bootchart|
|-|-|-|-|
|make build MODE=debug|7|No|Yes|
|make build MODE=dev|4|No|Yes|
|make build MODE=prod|3|Yes|No|

> [!IMPORTANT]
> Compilation takes approximately 40 minutes to 1 hour. It builds the `KBRD-OS` image as well as the `KBRD-DEV`, `KBRD-API`, and `KBRD-WEB` packages.

> [!NOTE]
> Once compilation is complete, the Raspberry image is available in `/output/images/kbrd.img`.

> [!TIP]
> It is possible to add `CLEAN=true` to delete the previous build.

## Image transfer

Check that the image is available in `/output/images/kbrd.img`. Connect the Raspberry to the computer via the USB-C port with the `BOOT` switch enabled.

Install pv:

```
sudo apt install pv
```

Compile usbboot:

```
make -C usbboot
```

For a first installation, or to completely rewrite the eMMC storage
(the `/data` partition and its database will be erased):

```
make flash-full
```

> [!NOTE]
> Once the image is installed, use `make flash` to update the boot and rootfs partitions without erasing the data stored in the `/data` partition.

> [!IMPORTANT]
> Once complete, disable `BOOT` mode using the switch and restart the Raspberry.

## SSH connection to the Raspberry

To update the Raspberry components, it is necessary to first define an SSH connection to the IP address associated with the keyboard.

Edit the configuration file:

```
sudo nano .ssh/config
```

Add the following configuration:

```
Host kbrd
    HostName {raspberry_ip_or_fqdn}
    User kbrd
    IdentityFile ~/.ssh/kbrd
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

## Component updates

`KBRD-DEV`, `KBRD-API`, and `KBRD-WEB` must be redeployed to the device after any update. To avoid systematically rebuilding the image and transferring it to the Raspberry, one of the following commands can be used:

|Command|Description|
|-|-|
|`make deploy`|Deploys all components|
|`make deploy PACKAGE=dev`|Deploys `KBRD-DEV`|
|`make deploy PACKAGE=api`|Deploys `KBRD-API`|
|`make deploy PACKAGE=web`|Deploys `KBRD-WEB`|
|`make deploy PACKAGE=plugins`|Deploys `KBRD-PLUGINS`|
|`make deploy PACKAGE=agent MACOS_HOST=mac MACOS_ARCH=arm64 KBRD_API_URL=http://kbrd.local:8081`|Builds and deploys `KBRD-AGENT` to the Mac over SSH|

> [!IMPORTANT]
> Deployment restarts the services associated with `KBRD-DEV` and `KBRD-API`.
