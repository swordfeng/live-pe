

mkdir generated
pushd generated

:: MBR
bcdedit /createstore bcd

bcdedit /store bcd /create {bootmgr}
bcdedit /store bcd /set {bootmgr} default {e94573e9-4762-11ec-a6e7-c115df973feb}
bcdedit /store bcd /set {bootmgr} timeout 30

bcdedit /store bcd /create {e94573e9-4762-11ec-a6e7-c115df973feb} /application osloader
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} description "Windows PE"
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} device ramdisk=[boot]\live\boot.wim,{ramdiskoptions}
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} osdevice ramdisk=[boot]\live\boot.wim,{ramdiskoptions}
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} path \windows\system32\boot\winload.exe
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} systemroot \windows
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} detecthal Yes
bcdedit /store bcd /set {e94573e9-4762-11ec-a6e7-c115df973feb} winpe Yes

bcdedit /store bcd /create {ramdiskoptions}
bcdedit /store bcd /set {ramdiskoptions} ramdisksdidevice boot
bcdedit /store bcd /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi

:: EFI
bcdedit /createstore bcd_efi

bcdedit /store bcd_efi /create {bootmgr}
bcdedit /store bcd_efi /set {bootmgr} default {e94573e9-4762-11ec-a6e7-c115df973feb}
bcdedit /store bcd_efi /set {bootmgr} timeout 30

bcdedit /store bcd_efi /create {e94573e9-4762-11ec-a6e7-c115df973feb} /application osloader
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} description "Windows PE"
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} device ramdisk=[boot]\live\boot.wim,{ramdiskoptions}
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} osdevice ramdisk=[boot]\live\boot.wim,{ramdiskoptions}
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} path \windows\system32\boot\winload.efi
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} systemroot \windows
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} detecthal Yes
bcdedit /store bcd_efi /set {e94573e9-4762-11ec-a6e7-c115df973feb} winpe Yes

bcdedit /store bcd_efi /create {ramdiskoptions}
bcdedit /store bcd_efi /set {ramdiskoptions} ramdisksdidevice boot
bcdedit /store bcd_efi /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi

popd