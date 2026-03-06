{
  config,
  pkgs,
  lib,
  ...
}: let
  isLaptop = config.var.hostname == "nixos";
in
  lib.mkIf isLaptop {
    # ─── Kernel power-saving parameters ──────────────────────────────────────
    boot.kernelParams = [
      # Enable ASPM (Active State Power Management) — lets PCIe devices
      # enter low-power states when idle. Critical for NVIDIA dGPU idle power.
      "pcie_aspm=force"

      # CPU: prefer energy-efficient cores on Intel hybrid CPUs
      # (12th gen+ Alder/Raptor Lake P/H series)
      "intel_pstate=active"

      # Disable CPU mitigations for a tiny perf/power win on a personal machine.
      # Remove this line if you're uncomfortable with that tradeoff.
      # "mitigations=off"

      # NMI watchdog burns CPU cycles; safe to disable on laptops
      "nmi_watchdog=0"

      # Reduce VM writeback timer (ms) — less frequent disk flushes = less wakeups
      "vm.dirty_writeback_centisecs=6000"
    ];

    boot.kernel.sysctl = {
      # Writeback: flush dirty pages after 60 s of inactivity (default 5 s)
      "vm.dirty_writeback_centisecs" = 6000;

      # Laptop mode: group disk I/O to reduce spinup frequency
      "vm.laptop_mode" = 5;
    };

    # ─── auto-cpufreq ─────────────────────────────────────────────────────────
    # Dynamically scales CPU frequency and governor (powersave on battery,
    # performance on AC) without manual intervention.
    # Disable power-profiles-daemon conflict: auto-cpufreq takes over that role.
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "auto"; # allow turbo only when needed, not always-on
          energy_performance_preference = "power";
          scaling_min_freq = 400000; # 400 MHz minimum
        };
        charger = {
          governor = "performance";
          turbo = "auto";
          energy_performance_preference = "performance";
        };
      };
    };

    # Disable power-profiles-daemon — conflicts with auto-cpufreq
    # (both try to own the cpufreq governor)
    services.power-profiles-daemon.enable = lib.mkForce false;

    # ─── TLP ─────────────────────────────────────────────────────────────────
    # Fine-grained per-device power management (USB autosuspend, PCIe ASPM,
    # SATA link power, NIC power save, disk APM, etc.)
    services.tlp = {
      enable = true;
      settings = {
        # ── CPU ──
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Intel HWP — let the CPU boost when needed on battery,
        # but don't lock it to max
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80; # cap at 80 % on battery

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0; # disable turbo boost on battery

        # HWP dynamic boost (Intel 10th gen+)
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        # ── Platform profile (system76-scheduler / firmware EC) ──
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # ── PCIe / ASPM ──
        # Force ASPM powersave on all PCIe links on battery — this is what
        # actually lets the NVIDIA dGPU clock-gate its PCIe link when idle.
        PCIE_ASPM_ON_AC = "performance";
        PCIE_ASPM_ON_BAT = "powersupersave";

        # ── NVMe ──
        AHCI_RUNTIME_PM_ON_AC = "on";
        AHCI_RUNTIME_PM_ON_BAT = "auto";

        # ── SATA ──
        SATA_LINKPWR_ON_AC = "max_performance";
        SATA_LINKPWR_ON_BAT = "min_power";

        # ── USB autosuspend ──
        # Suspend USB devices after 2 s of inactivity on battery.
        # Blacklist any devices that break under autosuspend (mice, etc.).
        USB_AUTOSUSPEND = 1;
        USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;

        # ── WiFi ──
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        # ── RUNTIME_PM (generic runtime power management for PCI devices) ──
        # This covers the NVIDIA dGPU PCI slot — enables D3 runtime suspend
        # when NVIDIA's own fine-grained PM is active.
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        # ── Battery care (Acer uses ACPI BAT0) ──
        # Charge thresholds extend battery lifespan significantly.
        # 20–80 % is a common longevity recommendation.
        # NOTE: Acer laptops may not support this via the standard ACPI interface;
        # if tlp-stat shows "not supported", these lines are safely ignored.
        START_CHARGE_THRESH_BAT0 = 20;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # ─── thermald ─────────────────────────────────────────────────────────────
    # Intel thermal daemon — prevents throttling by managing thermals
    # proactively rather than reactively. Works alongside TLP/auto-cpufreq.
    services.thermald.enable = true;

    # ─── powertop auto-tune on battery ────────────────────────────────────────
    # Runs `powertop --auto-tune` once after boot to enable all power hints
    # that TLP doesn't cover (e.g. runtime PM for individual kernel subsystems).
    powerManagement.powertop.enable = true;

    # ─── upower tweaks ───────────────────────────────────────────────────────
    services.upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 10;
      percentageAction = 5;
      criticalPowerAction = "Hibernate";
    };

    # ─── Packages ────────────────────────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      powertop # runtime power diagnostics — run `sudo powertop` to inspect
      tlp # CLI: tlp-stat, tlp start/stop
      acpi # quick battery status in terminal
      brightnessctl # already used in keybinds; listed here for completeness
    ];
  }
