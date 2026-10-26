# Mu-pipa USB lab

Experimental Mu-Silicium build for Xiaomi Pad 6 (`pipa`) focused on USB host
diagnostics.

Changes from upstream `pocketblue-pipa`:

- Always include Boot Manager and wait 15 seconds.
- Include UEFI Shell for `map -r`, `dh -p SimpleFileSystem`, and `ls`.
- Include the USB absolute-pointer mouse driver.
- Print USB host-controller, USB I/O, and filesystem handle counts at boot.
- Refresh boot options after USB enumeration and show a volume-key boot menu.
- Highlight the first UEFI-bootable USB device by default and boot the selected
  option after a 10-second timeout.
- Identify the platform as `Pad 6 USB Lab` in SMBIOS.
- Use the SM8250 `UsbConfigDxe.hostmode.efi` variant from the tested bitra
  platform instead of pipa's `patched.efi` USB configuration.

Build images with the `Build Mu-pipa USB lab` GitHub Actions workflow.

## Expected diagnostic line

```text
Mu-pipa USB lab: HC=N USB-IO=N filesystems=N inputs=N
```

Insert an OTG keyboard/storage and reboot:

- `HC` stays zero: no XHCI host controller was exposed.
- `HC` increases but `USB-IO` stays zero: controller exists, device enumeration fails.
- `USB-IO` increases but `filesystems` does not: storage or partition/FAT problem.
- `filesystems` increases: UEFI can see the drive; open Boot Manager or UEFI Shell.
- `inputs` increases but keys do not work: console binding still failed.
- A `USB:` line appears in the boot menu: UEFI found an EFI loader on the
  inserted USB device.

## Flash

Download the workflow artifact and run from PowerShell:

```powershell
.\Flash-Lab.ps1
```

The script refuses non-pipa devices and only writes to the current boot slot.
