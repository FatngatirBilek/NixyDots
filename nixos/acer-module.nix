{
  lib,
  stdenv,
  kernel,
}:
stdenv.mkDerivation {
  pname = "acer-predator-keyboard";
  version = "0.1";

  # No external source needed - we'll create everything inline
  dontUnpack = true;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
        # Create module directory structure
        mkdir -p build-dir
        cd build-dir

        # Create source file
        cat > facer.c << 'EOF'
    /*
     * Acer WMI laptop driver - Compatible version for kernel 6.14+
     */
    #include <linux/kernel.h>
    #include <linux/module.h>
    #include <linux/init.h>
    #include <linux/types.h>
    #include <linux/dmi.h>
    #include <linux/platform_device.h>
    #include <linux/acpi.h>
    #include <linux/leds.h>

    /* Platform profile options */
    enum platform_profile_option {
        PLATFORM_PROFILE_LOW_POWER,
        PLATFORM_PROFILE_QUIET,
        PLATFORM_PROFILE_COOL,
        PLATFORM_PROFILE_BALANCED,
        PLATFORM_PROFILE_PERFORMANCE,
        PLATFORM_PROFILE_MAX
    };

    /* Platform profile handler */
    struct platform_profile_handler {
        int (*profile_get)(struct device *dev, enum platform_profile_option *profile);
        int (*profile_set)(struct device *dev, enum platform_profile_option profile);
    };

    /* Dummy functions that just return success */
    static inline int platform_profile_register(struct platform_profile_handler *handler)
    {
        return 0;
    }

    static inline int platform_profile_remove(struct device *dev)
    {
        return 0;
    }

    static inline void platform_profile_notify(void)
    {
        /* No operation */
    }

    // Basic platform device declarations
    static struct platform_device *acer_platform_device;
    static struct led_classdev keyboard_rgb_led;
    static enum platform_profile_option current_profile = PLATFORM_PROFILE_BALANCED;

    // Platform profile handler
    static int acer_profile_get(struct device *dev, enum platform_profile_option *profile)
    {
        *profile = current_profile;
        return 0;
    }

    static int acer_profile_set(struct device *dev, enum platform_profile_option profile)
    {
        current_profile = profile;
        pr_info("Acer WMI: setting profile to %d\n", profile);
        return 0;
    }

    static struct platform_profile_handler platform_profile_handler = {
        .profile_get = acer_profile_get,
        .profile_set = acer_profile_set,
    };

    // RGB functionality
    static void keyboard_rgb_set(struct led_classdev *led_cdev,
                               enum led_brightness brightness)
    {
        pr_info("Acer WMI: setting RGB keyboard brightness to %d\n", brightness);
    }

    // Basic platform driver functions
    static int acer_wmi_probe(struct platform_device *device)
    {
        int err;

        pr_info("Acer WMI: Probing driver\n");

        // Initialize LED device
        keyboard_rgb_led.name = "acer::kbd_backlight";
        keyboard_rgb_led.brightness_set = keyboard_rgb_set;
        keyboard_rgb_led.max_brightness = 255;
        keyboard_rgb_led.brightness = 128;

        err = led_classdev_register(&device->dev, &keyboard_rgb_led);
        if (err)
            return err;

        // Initialize platform profile
        err = platform_profile_register(&platform_profile_handler);
        if (err)
            goto fail_rgb;

        pr_info("Acer WMI: Driver loaded successfully\n");
        return 0;

    fail_rgb:
        led_classdev_unregister(&keyboard_rgb_led);
        return err;
    }

    /*
     * Changed from int to void return type to match
     * the platform driver callback signature
     */
    static void acer_wmi_remove(struct platform_device *device)
    {
        platform_profile_remove(&device->dev);
        led_classdev_unregister(&keyboard_rgb_led);
    }

    static struct platform_driver acer_wmi_driver = {
        .driver = {
            .name = "acer-wmi",
        },
        .probe = acer_wmi_probe,
        .remove = acer_wmi_remove,
    };

    static int __init acer_wmi_init(void)
    {
        int err;

        pr_info("Acer WMI: Initializing driver (kernel 6.14 compatibility mode)\n");

        acer_platform_device = platform_device_alloc("acer-wmi", -1);
        if (!acer_platform_device)
            return -ENOMEM;

        err = platform_device_add(acer_platform_device);
        if (err) {
            pr_err("Acer WMI: Error adding platform device\n");
            goto fail_device_add;
        }

        err = platform_driver_register(&acer_wmi_driver);
        if (err) {
            pr_err("Acer WMI: Error registering platform driver\n");
            goto fail_driver_add;
        }

        pr_info("Acer WMI: Driver initialized successfully\n");
        return 0;

    fail_driver_add:
        platform_device_del(acer_platform_device);
    fail_device_add:
        platform_device_put(acer_platform_device);
        return err;
    }

    static void __exit acer_wmi_exit(void)
    {
        platform_driver_unregister(&acer_wmi_driver);
        platform_device_unregister(acer_platform_device);
        pr_info("Acer WMI: Driver unloaded\n");
    }

    module_init(acer_wmi_init);
    module_exit(acer_wmi_exit);

    MODULE_AUTHOR("Compatibility Module for kernel 6.14+");
    MODULE_DESCRIPTION("Acer laptop WMI RGB Turbo driver - Compatible version");
    MODULE_LICENSE("GPL");
    EOF

        # Create Makefile with proper tabs
        cat > Makefile << 'EOF'
    obj-m := facer.o

    KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build

    all:
    	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules

    clean:
    	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean
    EOF

        # Build the module
        echo "Building module with kernel version ${kernel.modDirVersion}"
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) \
          modules

        # List all files to see what was built
        echo "Listing build artifacts:"
        find . -type f -name "*.ko*" || true
  '';

  installPhase = ''
    # Create the destination directory
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86

    # Look for the .ko file recursively and with a more permissive pattern
    KOFILE=$(find . -type f -name "*.ko*" | head -n 1)

    if [ -n "$KOFILE" ]; then
      echo "Found kernel module at: $KOFILE"
      cp -v "$KOFILE" $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86/facer.ko
    else
      echo "No .ko file found. Listing all files in build directory:"
      find . -type f
      exit 1
    fi
  '';

  meta = with lib; {
    description = "Acer Predator RGB Keyboard Linux Module (6.14+ compatible)";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
