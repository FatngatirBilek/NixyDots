# - ## Nixy Cache
#-
#- Nixy Cache is a companion script to `nixy` that checks, before you commit to
#- a rebuild, how much of your flake's closure is actually sitting in a binary
#- cache versus how much nix is about to compile from source on your machine.
#-
#- Born out of a night where `nixos-unstable` was freshly "Rolling" on
#- status.nixos.org but most individual packages hadn't finished building on
#- Hydra yet, so a routine `nixos-rebuild switch` turned into a 12+ hour
#- from-source rebuild of Mesa, Hyprland, WebKitGTK, and half of KDE.
#-
#- - `nixy-cache` / `nixy-cache check` - Dry-build the current flake target and
#-   report how many derivations will be BUILT (bad) vs FETCHED (good), plus
#-   total download size.
#- - `nixy-cache list` - Same as check, but also dumps the full "will be built"
#-   list into a temp file and shows it to you (grouped loosely by whether it
#-   looks unfree/third-party-flake vs plain nixpkgs, since the former will
#-   basically never be cached and the latter is what you should worry about).
#- - `nixy-cache probe <store-path>` - Check a single /nix/store/... path against
#-   cache.nixos.org directly, without doing a full dry-build.
#- - `nixy-cache probe <package-name> [commit]` - Same, but you can pass a plain
#-   nixpkgs attribute name (e.g. "fastfetch", "hyprland", "mesa") instead of a
#-   store path. Resolves the path for you via `nix eval`. If [commit] is
#-   omitted, it uses whatever nixpkgs commit your flake.lock is currently
#-   pinned to.
#- - `nixy-cache try <commit>` - Temporarily point flake.nix's nixpkgs input at
#-   a specific commit (a backup of flake.nix is made first), update the lock,
#-   and dry-build, so you can compare a candidate commit's cache-hit rate
#-   before committing to it. Does NOT touch flake.lock permanently until you
#-   run `nixy-cache keep`.
#- - `nixy-cache revert` - Restore flake.nix + flake.lock from the backup made
#-   by the last `try`.
#- - `nixy-cache keep` - Drop the backup, i.e. confirm you want to stay on the
#-   commit you just tried.
#- - `nixy-cache status` - Open status.nixos.org in your default browser so you
#-   can eyeball which channel/commit is currently marked green, as a starting
#-   point (not a guarantee — always confirm with `check` after).
{
  pkgs,
  config,
  ...
}: let
  configDirectory = config.var.configDirectory;
  hostname = config.var.hostname;
  nixyCache =
    pkgs.writeShellScriptBin "nixy-cache"
    # bash
    ''
      set -uo pipefail

      FLAKE_TARGET="${configDirectory}#${hostname}"
      FLAKE_FILE="${configDirectory}/flake.nix"
      LOCK_FILE="${configDirectory}/flake.lock"
      BACKUP_DIR="/tmp/nixy-cache-backup"
      DRYBUILD_OUT="/tmp/nixy-cache-drybuild.txt"

      RED=$'\033[0;31m'
      GREEN=$'\033[0;32m'
      YELLOW=$'\033[1;33m'
      BLUE=$'\033[0;34m'
      BOLD=$'\033[1m'
      RESET=$'\033[0m'

      function run_drybuild() {
        echo "''${BLUE}Running dry-build against ''${FLAKE_TARGET}...''${RESET}"
        nixos-rebuild dry-build --flake "''${FLAKE_TARGET}" > "''${DRYBUILD_OUT}" 2>&1
        if ! grep -qE "will be (built|fetched)" "''${DRYBUILD_OUT}"; then
          echo "''${RED}dry-build produced no build/fetch summary, dumping raw output:''${RESET}"
          cat "''${DRYBUILD_OUT}"
          exit 1
        fi
      }

      function summarize() {
        built=$(grep -oE "these [0-9]+ derivations will be built" "''${DRYBUILD_OUT}" | grep -oE "[0-9]+" || echo 0)
        fetched_line=$(grep -oE "these [0-9]+ paths will be fetched \([^)]*\)" "''${DRYBUILD_OUT}" || echo "")
        fetched=$(echo "''${fetched_line}" | grep -oE "^these [0-9]+" | grep -oE "[0-9]+" || echo 0)
        size=$(echo "''${fetched_line}" | grep -oE "\([^)]*\)" || echo "(n/a)")

        echo ""
        echo "''${BOLD}=== Cache summary for ''${FLAKE_TARGET} ===''${RESET}"
        echo "''${RED}Will be BUILT from source:  ''${built}''${RESET}"
        echo "''${GREEN}Will be FETCHED from cache: ''${fetched} ''${size}''${RESET}"
        echo ""

        if [[ "''${built}" -gt 100 ]]; then
          echo "''${YELLOW}⚠ That's a lot of from-source builds. Possible causes:''${RESET}"
          echo "  - nixpkgs commit is too fresh, Hydra hasn't finished caching it yet"
          echo "    -> try: nixy-cache try <older-commit-hash>"
          echo "  - unfree packages (steam, nvidia, discord, etc.) - never cached, unavoidable"
          echo "  - third-party flakes (dms-shell, zen-browser, ghostty, etc.) - never cached upstream"
          echo "  - a global overlay/packageOverride touching something low in the dep tree (e.g. stdenv, glibc, gnugrep)"
          echo ""
          echo "Run 'nixy-cache list' to see the actual list and eyeball which category dominates."
        elif [[ "''${built}" -gt 0 ]]; then
          echo "''${GREEN}Looks reasonable - the rest is probably just unfree/third-party/config-glue derivations.''${RESET}"
        else
          echo "''${GREEN}Fully cached. Safe to switch.''${RESET}"
        fi
      }

      function cmd_check() {
        run_drybuild
        summarize
      }

      function cmd_list() {
        run_drybuild
        summarize
        echo ""
        echo "''${BOLD}Full 'will be built' list saved to ''${DRYBUILD_OUT}''${RESET}"
        echo "''${BOLD}Opening a quick categorized peek:''${RESET}"
        echo ""
        echo "''${YELLOW}--- likely unfree / third-party (expected, ignore) ---''${RESET}"
        grep -E "\.drv$" "''${DRYBUILD_OUT}" | grep -iE "steam|nvidia|discord|lunarclient|chrome|bitwarden|cuda|dms-shell|zen-browser|ghostty|osu-lazer|electron|obsidian|antigravity|onlyoffice|mongodb" || echo "  (none matched)"
        echo ""
        echo "''${RED}--- everything else in the build list (worth investigating if long) ---''${RESET}"
        grep -E "\.drv$" "''${DRYBUILD_OUT}" | grep -ivE "steam|nvidia|discord|lunarclient|chrome|bitwarden|cuda|dms-shell|zen-browser|ghostty|osu-lazer|electron|obsidian|antigravity|onlyoffice|mongodb|unit-|etc-|hm_|X-Restart|X-Reload|dconf|activation-script|system-path|system-units|system-generators|user-generators|user-units|user-environment" || echo "  (none - looks like just config glue + unfree + 3rd party, that's normal)"
      }

      function current_nixpkgs_rev() {
        # Properly resolve which node name the root flake's "nixpkgs" input
        # points to, then read that node's locked rev. Grepping for the first
        # literal "nixpkgs": { in flake.lock is NOT safe - third-party inputs
        # (e.g. apple-fonts, chaotic) often carry their own separately-pinned
        # nixpkgs copies as sibling nodes named "nixpkgs", "nixpkgs_2", etc,
        # and the root's own nixpkgs input may not be the first one in the file.
        local root_node
        root_node=$(${pkgs.jq}/bin/jq -r '.nodes.root.inputs.nixpkgs' "''${LOCK_FILE}" 2>/dev/null)
        if [[ -z "''${root_node}" || "''${root_node}" == "null" ]]; then
          return 1
        fi
        ${pkgs.jq}/bin/jq -r --arg n "''${root_node}" '.nodes[$n].locked.rev // empty' "''${LOCK_FILE}" 2>/dev/null
      }

      function cmd_probe() {
        input="''${1:-}"
        commit="''${2:-}"

        if [[ -z "''${input}" ]]; then
          echo "Usage:"
          echo "  nixy-cache probe /nix/store/hash-name"
          echo "  nixy-cache probe <package-name> [commit]"
          exit 1
        fi

        if [[ "''${input}" == /nix/store/* ]]; then
          path="''${input}"
        else
          if [[ -z "''${commit}" ]]; then
            commit=$(current_nixpkgs_rev)
            if [[ -z "''${commit}" ]]; then
              echo "''${RED}Could not determine current nixpkgs commit from ''${LOCK_FILE}.''${RESET}"
              echo "Pass one explicitly: nixy-cache probe ''${input} <commit>"
              exit 1
            fi
            echo "''${BLUE}Using current flake's nixpkgs commit: ''${commit}''${RESET}"
          fi
          echo "''${BLUE}Resolving package ''${input} at commit ''${commit}...''${RESET}"
          path=$(nix eval --raw "github:nixos/nixpkgs/''${commit}#''${input}.outPath" 2>/dev/null)
          if [[ -z "''${path}" ]]; then
            echo "''${RED}Could not resolve package ''${input} at commit ''${commit}.''${RESET}"
            echo "Check the attribute name, or that it exists at that commit."
            exit 1
          fi
          echo "''${BLUE}-> ''${path}''${RESET}"
        fi

        if nix path-info --store https://cache.nixos.org "''${path}" 2>/dev/null; then
          echo "''${GREEN}✓ Cached''${RESET}"
        else
          echo "''${RED}✗ NOT in cache.nixos.org''${RESET}"
        fi
      }

      function cmd_try() {
        if [[ -z "''${1:-}" ]]; then
          echo "Usage: nixy-cache try <nixpkgs-commit-hash>"
          exit 1
        fi
        mkdir -p "''${BACKUP_DIR}"
        cp "''${FLAKE_FILE}" "''${BACKUP_DIR}/flake.nix.bak"
        cp "''${LOCK_FILE}" "''${BACKUP_DIR}/flake.lock.bak"
        echo "''${BLUE}Backed up flake.nix + flake.lock to ''${BACKUP_DIR}''${RESET}"

        sed -i -E 's#(nixpkgs\.url = ")github:nixos/nixpkgs/[^"]+(")#\1github:nixos/nixpkgs/'"$1"'\2#' "''${FLAKE_FILE}"
        echo "''${BLUE}Set nixpkgs.url to commit $1''${RESET}"

        (cd "${configDirectory}" && nix flake lock --update-input nixpkgs)

        cmd_check
        echo ""
        echo "''${YELLOW}This is a trial change. Run 'nixy-cache keep' to make it permanent,''${RESET}"
        echo "''${YELLOW}or 'nixy-cache revert' to undo and go back to what you had before.''${RESET}"
      }

      function cmd_revert() {
        if [[ ! -f "''${BACKUP_DIR}/flake.nix.bak" ]]; then
          echo "''${RED}No backup found at ''${BACKUP_DIR}. Nothing to revert.''${RESET}"
          exit 1
        fi
        cp "''${BACKUP_DIR}/flake.nix.bak" "''${FLAKE_FILE}"
        cp "''${BACKUP_DIR}/flake.lock.bak" "''${LOCK_FILE}"
        rm -rf "''${BACKUP_DIR}"
        echo "''${GREEN}Reverted flake.nix + flake.lock from backup.''${RESET}"
      }

      function cmd_keep() {
        if [[ ! -d "''${BACKUP_DIR}" ]]; then
          echo "''${YELLOW}No pending trial to keep.''${RESET}"
          exit 0
        fi
        rm -rf "''${BACKUP_DIR}"
        echo "''${GREEN}Keeping current nixpkgs pin. Backup discarded.''${RESET}"
      }

      function cmd_status() {
        url="https://status.nixos.org"
        echo "Opening ''${url} - look for nixos-unstable's commit + Rolling status."
        echo "Remember: green/Rolling means evaluation passed, NOT that every package is cached yet."
        echo "Always confirm with 'nixy-cache check' after picking a commit."
        xdg-open "''${url}" >/dev/null 2>&1 || echo "Could not auto-open browser, visit: ''${url}"
      }

      case "''${1:-check}" in
        check)   cmd_check ;;
        list)    cmd_list ;;
        probe)   cmd_probe "''${2:-}" "''${3:-}" ;;
        try)     cmd_try "''${2:-}" ;;
        revert)  cmd_revert ;;
        keep)    cmd_keep ;;
        status)  cmd_status ;;
        *)
          echo "Unknown subcommand: ''${1}"
          echo "Usage: nixy-cache [check|list|probe <path>|try <commit>|revert|keep|status]"
          exit 1
          ;;
      esac
    '';
in {
  home.packages = [nixyCache];
}
