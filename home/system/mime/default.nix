{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/markdown" = "nvim.desktop";
      "text/plain" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "text/x-python" = "nvim.desktop";
      "text/x-go" = "nvim.desktop";
      "text/css" = "nvim.desktop";
      "text/javascript" = "nvim.desktop";
      "text/x-c" = "nvim.desktop";
      "text/x-c++" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-rust" = "nvim.desktop";
      "text/x-yaml" = "nvim.desktop";
      "text/x-toml" = "nvim.desktop";
      "text/x-dockerfile" = "nvim.desktop";
      "text/x-xml" = "nvim.desktop";
      "text/x-php" = "nvim.desktop";
      "image/jpeg" = "swayimg.desktop";
      "image/jpg" = "swayimg.desktop";
      "image/webp" = "swayimg.desktop";
      "image/gif" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "text/html" = "zen.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "image/png" = "swayimg.desktop";
      "x-scheme-handler/chrome" = "zen.desktop";
      "application/x-extension-htm" = "zen.desktop";
      "application/x-extension-html" = "zen.desktop";
      "application/x-extension-shtml" = "zen.desktop";
      "application/xhtml+xml" = "zen.desktop";
      "application/x-extension-xhtml" = "zen.desktop";
      "application/x-extension-xht" = "zen.desktop";

      # --- Archive formats -> File Roller ---
      # Tar family
      "application/x-tar" = "org.gnome.FileRoller.desktop";
      "application/x-compressed-tar" = "org.gnome.FileRoller.desktop"; # .tar.gz, .tgz
      "application/x-bzip-compressed-tar" = "org.gnome.FileRoller.desktop"; # .tar.bz2, .tbz2, .tar.bz, .tbz
      "application/x-lzma-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-tzo" = "org.gnome.FileRoller.desktop"; # .tar.lzo, .tzo
      "application/x-tarz" = "org.gnome.FileRoller.desktop"; # .tar.Z, .taz

      # Zip & Java
      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/java-archive" = "org.gnome.FileRoller.desktop"; # .jar, .ear, .war

      # Popular formats
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      "application/vnd.rar" = "org.gnome.FileRoller.desktop";
      "application/x-rar" = "org.gnome.FileRoller.desktop";
      "application/x-lha" = "org.gnome.FileRoller.desktop"; # .lzh, .lha
      "application/x-arj" = "org.gnome.FileRoller.desktop";

      # Single-file compression
      "application/gzip" = "org.gnome.FileRoller.desktop";
      "application/x-bzip" = "org.gnome.FileRoller.desktop";
      "application/x-bzip2" = "org.gnome.FileRoller.desktop";
      "application/x-compress" = "org.gnome.FileRoller.desktop"; # .Z
      "application/x-lzop" = "org.gnome.FileRoller.desktop";
      "application/zstd" = "org.gnome.FileRoller.desktop";
      "application/x-bzip3" = "org.gnome.FileRoller.desktop";

      # Extra read/extract-only formats
      "application/x-ace" = "org.gnome.FileRoller.desktop";
      "application/x-alz" = "org.gnome.FileRoller.desktop";
      "application/x-archive" = "org.gnome.FileRoller.desktop"; # .ar
      "application/x-cab" = "org.gnome.FileRoller.desktop";
      "application/x-cpio" = "org.gnome.FileRoller.desktop";

      # Install packages & disk images (read-only mode)
      "application/vnd.debian.binary-package" = "org.gnome.FileRoller.desktop"; # .deb
      "application/x-rpm" = "org.gnome.FileRoller.desktop";
      "application/x-apple-diskimage" = "org.gnome.FileRoller.desktop"; # .dmg
      "application/x-cd-image" = "org.gnome.FileRoller.desktop"; # .iso
      "application/x-cbr" = "org.gnome.FileRoller.desktop"; # .cbr
    };
  };
}
