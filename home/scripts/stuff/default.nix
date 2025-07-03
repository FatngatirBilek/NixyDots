{
  pkgs,
  user,
  ...
}: {
  home.packages = [
    (
      pkgs.writers.writePython3Bin "krisp-patcher"
      {
        libraries = with pkgs.python3Packages; [
          capstone
          pyelftools
        ];
        flakeIgnore = [
          "E501" # line too long (82 > 79 characters)
          "F403" # 'from module import *' used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      }
      ''
        import sys
        import shutil

        from elftools.elf.elffile import ELFFile
        from capstone import *
        from capstone.x86 import *

        if len(sys.argv) < 2:
            print(f"Usage: {sys.argv[0]} [path to discord_krisp.node]")
            sys.exit(2)

        executable = sys.argv[1]
        elf = ELFFile(open(executable, "rb"))
        symtab = elf.get_section_by_name('.symtab')

        krisp_initialize_address = symtab.get_symbol_by_name("_ZN7discordL17DoKrispInitializeEv")[0].entry.st_value
        isSignedByDiscord_address = symtab.get_symbol_by_name("_ZN7discord4util17IsSignedByDiscordERKNSt4__Cr12basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEE")[0].entry.st_value

        text = elf.get_section_by_name('.text')
        text_start = text['sh_addr']
        text_start_file = text['sh_offset']
        address_to_file = text_start_file - text_start

        krisp_initialize_offset = krisp_initialize_address - address_to_file
        isSignedByDiscord_offset = krisp_initialize_address - address_to_file

        f = open(executable, "rb")
        f.seek(krisp_initialize_offset)
        krisp_initialize = f.read(256)
        f.close()

        found_issigned_by_discord_call = False
        found_issigned_by_discord_test = False
        found_issigned_by_discord_je = False
        found_already_patched = False
        je_location = None
        je_size = 0

        md = Cs(CS_ARCH_X86, CS_MODE_64)
        md.detail = True
        for i in md.disasm(krisp_initialize, krisp_initialize_address):
            if i.id == X86_INS_CALL:
                if i.operands[0].type == X86_OP_IMM:
                    if i.operands[0].imm == isSignedByDiscord_address:
                        found_issigned_by_discord_call = True

            if i.id == X86_INS_TEST:
                if found_issigned_by_discord_call:
                    found_issigned_by_discord_test = True

            if i.id == X86_INS_JE:
                if found_issigned_by_discord_test:
                    found_issigned_by_discord_je = True
                    je_location = i.address
                    je_size = len(i.bytes)
                    break

            if i.id == X86_INS_NOP:
                if found_issigned_by_discord_test:
                    found_already_patched = True
                    break

        if je_location:
            print(f"Found patch location: 0x{je_location:x}")

            shutil.copyfile(executable, executable + ".orig")
            f = open(executable, 'rb+')
            f.seek(je_location - address_to_file)
            f.write(b'\x90' * je_size)
            f.close()
        else:
            if found_already_patched:
                print("Couldn't find patch location - already patched.")
            else:
                print("Couldn't find patch location - review manually. Sorry.")
      ''
    )
    (pkgs.writeShellScriptBin "dinfo" ''
      Kernel="$(uname -r)"
      uptime="$(uptime -p | sed 's/up //')"

      tooltip+="<b>SystemInfo:</b>\n"
      tooltip+="Kernel: $Kernel\n"
      tooltip+="Uptime: $uptime"

      cat <<EOF
      { "text":"", "tooltip":"$tooltip", "class":""}
      EOF
    '')
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ''${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
    '')
    (pkgs.writeShellScriptBin "dmenu" ''
      rofi -dmenu "$@"
    '')
    (pkgs.writeShellScriptBin "gpu" ''
      usage=$(nvidia-smi | grep % | cut -b 73,74,75,76,77 | sed 's/ //g')
      temp=$(nvidia-smi | grep % | cut -b 9,10)
      text="<span color='#02a62d'>  $usage  󰢮 </span>"
      tooltip="GPU Usage: $usage\rGPU Temp: $temp°C"
      cat <<EOF
      {"text":"$text","tooltip":"$tooltip",}
      EOF
    '')
    (pkgs.writeShellScriptBin "amd-gpu" ''
      if test -f /sys/class/hwmon/hwmon0/device/gpu_busy_percent; then
        usage=$(cat /sys/class/hwmon/hwmon0/device/gpu_busy_percent)
        num=0
      elif test -f /sys/class/hwmon/hwmon1/device/gpu_busy_percent; then
        usage=$(cat /sys/class/hwmon/hwmon1/device/gpu_busy_percent)
        num=1
      elif test -f /sys/class/hwmon/hwmon2/device/gpu_busy_percent; then
        usage=$(cat /sys/class/hwmon/hwmon2/device/gpu_busy_percent)
        num=2
      elif test -f /sys/class/hwmon/hwmon3/device/gpu_busy_percent; then
        usage=$(cat /sys/class/hwmon/hwmon3/device/gpu_busy_percent)
        num=3
      elif test -f /sys/class/hwmon/hwmon4/device/gpu_busy_percent; then
        usage=$(cat /sys/class/hwmon/hwmon4/device/gpu_busy_percent)
        num=4
      fi
      name=$(lspci | grep VGA | cut -d ":" -f3 | cut -d "[" -f3 | cut -d "]" -f1)
      temp1=$(cat /sys/class/hwmon/hwmon''${num}/temp1_input)
      temp=$(echo $temp1 | rev | cut -c 4- | rev)
      text="<span color='#990000'>  ''${usage}%  󰢮 </span>"
      tooltip="$name\rGPU Usage: ''${usage}%\rGPU Temp: $temp°C"
      cat <<EOF
      {"text":"$text","tooltip":"$tooltip",}
      EOF
    '')
    (pkgs.writeShellScriptBin "nixos" ''
      cat <<EOF
      {"text":"<span color='#4575DA'> </span>","tooltip":"<span color='#4575DA'>⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣷⣤⣙⢻⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⡿⠛⠛⠿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀\r⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⠿⣆⠀⠀⠀⠀\r⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀\r⠀⢀⣾⣿⣿⠿⠟⠛⠋⠉⠉⠀⠀⠀⠀⠀⠀⠉⠉⠙⠛⠻⠿⣿⣿⣷⡀⠀\r⣠⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣄</span>",}
      EOF
    '')
    (pkgs.writeShellScriptBin "nixos.sh" ''
      echo -n $'\E[34m'
      cat << "EOF"
               _  _ _      ___  ___
           							      | \| (_)_ __/ _ \/ __|
        							      | .` | \ \ / (_) \__ \
         					 		      |_|\_|_/_\_\\___/|___/
      EOF
    '')
    (pkgs.writeShellScriptBin "update-cloudflare-dns" ''... '')
    (pkgs.writeShellScriptBin "gamemode.sh" ''... '')
    (pkgs.writeShellScriptBin "sheesh.sh" "pkexec env PATH=$PATH HOME=$HOME DISPLAY=$DISPLAY WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_SESSION_TYPE=$XDG_SESSION_TYPE XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR neovide /etc/nixos")
    (pkgs.writeShellScriptBin "finder.sh" ''... '')
    (pkgs.writeShellScriptBin "startup-sound" ''... '')
    (pkgs.writeShellScriptBin "update-damn-nixos" ''... '')
    (pkgs.writeShellScriptBin "toggle-restriction" ''... '')
  ];
}
