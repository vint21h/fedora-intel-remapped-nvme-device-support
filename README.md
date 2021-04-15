[//]: # (fedora-intel-remapped-nvme-device-support)
[//]: # (README.md)


# Fedora Intel remapped NVME device support

Contents
* [Problem](#problem)
* [Possible solutions](#possible-solutions)
* [Build a custom kernel](#build-a-custom-kernel)
* [Build custom installation media](#build-custom-installation-media)
* [Licensing](#licensing)
* [Contacts](#contacts)

## Problem
Some new laptops, like [HP ENVY 15 Laptop](https://www.hp.com/us-en/shop/mdp/laptops/envy-15-204072--1) or [DELL Inspiron 7490](https://www.dell.com/community/Linux-General/Inspiron-7490-BIOS-How-to-turn-off-intel-RAID-on-and-swith-disk/td-p/7388147), have problem with linux installation/work.
The reason is the manufacturers use Intel Rapid Storage Technology with NVME disks and, accordingly, in the UEFI of these devices [there is no possibility to switch these drives to AHCI mode](https://h30434.www3.hp.com/t5/Notebook-Boot-and-Lockup/envy-15-2020-ahci-mode/td-p/7703443>).

The modern version of the Linux kernel does not provide support for this technology in such a combination and only shows a warning to the user to change the mode of the disks.
There are two sets of patches to make these disks work, from [Dan Williams](https://marc.info/?l=linux-ide&m=147709610621480&w=2), and another one from [Daniel Drake](https://lkml.org/lkml/2019/6/20/27) based on previous, but they have not been merged into the mainline kernel.

Bad thing - both of them are not applicable for the latest kernel version.

Good thing - Daniel Drake supports his patch in [Endless OS](https://endlessos.com/) custom kernel.

## Possible solutions
* Install and use [Endless OS](https://endlessos.com/).
* Build Fedora custom live/installation media with a custom kernel with applied remapped NVME device support patch.

[//]: # (TODO: add a link to ISO)
* Download custom live/installation media built by a random guy from teh internets and use it at your own risk.

## Build a custom kernel
Another machine with Fedora and configured sudo is required.

1. Install build tools:
    ```sh
    $ sudo dnf install fedpkg fedora-packager rpmdevtools ncurses-devel pesign grubby
    ```
2. Create working directory and enter to it:
    ```sh
    $ mkdir fedora-custom-kernel
    ```
3. Get kernel package sources:
    ```sh
    $ fedpkg clone -a kernel
    ```
4. Enter to the package source directory:
    ```sh
    $ cd kernel
    ```
5. Switch to desired fedora kernel branch:
    ```sh
    $ git checkout -b local origin/f33
    ```
6. Install kernel build requirements:
   ```sh
   $ sudo dnf builddep kernel.spec
   ```
7. Get a patch from [Endless OS kernel repository](https://github.com/endlessm/linux/), it can be found by searching commit with [PCI: Add Intel remapped NVMe device support](https://github.com/endlessm/linux/commit/085cc1148ff1e9bcf7d3245a53b240d6e90fb90d) name.
    ```sh
    $ wget -c https://github.com/endlessm/linux/commit/085cc1148ff1e9bcf7d3245a53b240d6e90fb90d.patch -O patch-intel-remapped-nvme-device-support.patch
    ```
8. Update kernel package spec file (kernel.spec):
    1. Replace `# define buildid .local` by `%define buildid .local`
    2. Add `Patch2: patch-intel-remapped-nvme-device-support.patch` line after `Patch1: patch-%{stableversion}-redhat.patch`
    3. Add `ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch` line after `ApplyOptionalPatch patch-%{stableversion}-redhat.patch`

    Or using command line:
    ```sh
    $ sed -i 's/# define buildid .local/%define buildid .local/g' kernel.spec
    $ sed -i '/^Patch1: patch-%{stableversion}-redhat.patch/a Patch2: patch-intel-remapped-nvme-device-support.patch' kernel.spec
    $ sed -i '/^ApplyOptionalPatch patch-%{stableversion}-redhat.patch/a ApplyOptionalPatch patch-intel-remapped-nvme-device-support.patch' kernel.spec
    ```
9. Build source package (optional):
    ```sh
    $ fedpkg srpm
    ```
10. Build kernel packages:
    ```sh
    $ fedpkg local
    ```

Or just use `build-kernel.sh` script from this repository.
Freshly built packages can be found in `fedora-custom-kernel/kernel/x86_64` directory.

# Build custom installation media
[//]: # (TODO: document it!!1)
1. Install build tools:
    ```sh
    $ sudo dnf install lorax fedora-kickstarts pykickstart createrepo_c
    ```
2. Enter to the directory with fresh build kernel packages:
    ```sh
    $ cd fedora-custom-kernel/kernel/x86_64
    ```
3. Create repo metadata:
    ```sh
    $ createrepo .
    ```
4. Switch to main directory:
    ```sh
    $ cd ../..
    ```
5. Create image build directory:
    ```sh
    $ mkdir image
    ```
6. Enter image build directory:
    ```sh
    $ cd image
    ```
7. Build boot image:
    ```sh
    $ sudo sh -c 'setenforce 0 && lorax -p Fedora\ 33 -v 33 -r 33 -s http://localhost:8080/ -s https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Everything/x86_64/os/ -s https://dl.fedoraproject.org/pub/fedora/linux/updates/33/Everything/x86_64/ ./result/ && setenforce 1'
    ```
8. Create flat kickstart file:
    ```sh
    $ ksflatten --config /usr/share/spin-kickstarts/fedora-live-workstation.ks -o flat-fedora-live-workstation.ks --version F33
    ```
9. Update kickstart file:
    ```sh
    $ sed -i 's#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch"#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever\&arch=$basearch"#g' flat-fedora-live-workstation.ks
    $ sed -i 's#repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#\# repo --name="rawhide" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=rawhide\&arch=$basearch#g' flat-fedora-live-workstation.ks
    $ sed -i '/^# repo --name="rawhide" --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=rawhide\&arch=$basearch/a repo --name=fedora --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-$releasever\&arch=$basearch' flat-fedora-live-workstation.ks
    $ sed -i '/^repo --name=fedora --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=fedora-$releasever\&arch=$basearch/a repo --name=updates --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-$releasever\&arch=$basearch' flat-fedora-live-workstation.ks
    $ sed -i '/^repo --name=updates --mirrorlist=https:\/\/mirrors.fedoraproject.org\/mirrorlist?repo=updates-released-$releasever\&arch=$basearch/a repo --name=fedora-custom-kernel --cost=1 --baseurl=https://fedora-custom-kernel-repo.s3.amazonaws.com/$releasever/$basearch/' flat-fedora-live-workstation.ks
    ```
10. Build live/installation media image:
    ```sh
    $ sudo sh -c 'setenforce 0 && livemedia-creator --make-iso --iso=result/images/boot.iso --ks flat-fedora-live-workstation.ks --releasever=33 --macboot --resultdir=./live/ --live-rootfs-size 10 && setenforce 1'
    ```

Or just use `build-image.sh` script from this repository.

## Licensing
fedora-intel-remapped-nvme-device-support uses the Creative Commons Attribution Share Alike 4.0 International license.
Please check the LICENSE file for more details.

## Contacts
**Author**: Alexei Andrushievich <vint21h@vint21h.pp.ua>
